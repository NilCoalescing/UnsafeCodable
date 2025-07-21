//
//  BoundedMutableRawPointer.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation


public struct BoundedMutableRawPointer: ~Copyable {
    public private(set) var length: Int
    public private(set) var ptr: UnsafeMutableRawPointer
    
    /// Creates a new bounded mutable raw pointer.
    /// - Parameters:
    ///   - length: The number of bytes available in the region.
    ///   - ptr: The starting address of the writable memory region. This pointer is consumed.
    public init(length: Int, consuming ptr: consuming UnsafeMutableRawPointer) {
        self.length = length
        self.ptr = ptr
    }
    
    /// Creates a bounded mutable raw pointer from an UnsafeMutableRawBufferPointer.
    /// - Parameter buffer: The raw buffer pointer representing the writable memory region. This buffer is consumed.
    public init(consuming buffer: consuming UnsafeMutableRawBufferPointer) {
        self.length = buffer.count
        self.ptr = buffer.baseAddress!
    }

    /// Creates a bounded mutable raw pointer from an UnsafeMutableBufferPointer of a specific type.
    /// - Parameter buffer: The typed buffer pointer representing the writable memory region. This buffer is consumed.
    public init<T>(consuming buffer: consuming UnsafeMutableBufferPointer<T>) {
        self.length = buffer.count * MemoryLayout<T>.stride
        self.ptr = UnsafeMutableRawPointer(buffer.baseAddress!)
    }
    
    /// Writes a single value of type `T` into the buffer and advances the pointer.
    /// - Parameter value: The value to write. Must conform to `BitwiseCopyable`.
    /// - Throws: `UnsafeCodableError.outOfBounds` if there is insufficient space,
    ///   or another `UnsafeCodableError` if writing fails.
    /// - Note: Advances the pointer and reduces length by the size of `T`.
    public mutating func write<T>(value: T) throws(UnsafeCodableError) where T: BitwiseCopyable {
        let size = MemoryLayout<T>.size
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        self.ptr.assumingMemoryBound(to: T.self).pointee = value
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
    }
    
    /// Writes an array of values of type `T` into the buffer, prefixed by its count.
    /// - Parameter array: The array to write. Elements must conform to `BitwiseCopyable`.
    /// - Throws: `UnsafeCodableError` if there is insufficient space or writing fails.
    public mutating func write<T>(array: [T]) throws(UnsafeCodableError) where T: BitwiseCopyable {
        try self.write(value: array.count)
        try self.writeRaw(array: array)
    }
    
    
    /// Writes an array of values of type `T` directly into the buffer.
    /// - Parameter array: The array of values to write.
    /// - Throws: `UnsafeCodableError` if the buffer is too small or writing fails.
    /// - Note: Does not write a length prefix.
    private mutating func writeRaw<T>(array: [T]) throws(UnsafeCodableError) where T: BitwiseCopyable {
        let size = MemoryLayout<T>.stride * array.count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        do {
            try array.withContiguousStorageIfAvailable { ptr in
                guard let baseAddress = ptr.baseAddress else {
                    throw UnsafeCodableError.unableToUnwrap
                }
                self.ptr.copyMemory(from: baseAddress, byteCount: size)
            }
        } catch (let error as UnsafeCodableError) {
            throw error
        } catch {
            throw UnsafeCodableError.memoryError
        }
        
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
    }
    
    internal mutating func write(_ data: Data) throws(UnsafeCodableError) {
        let size = data.count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        data.withUnsafeBytes { sourcePTR in
            ptr.copyMemory(from: sourcePTR.baseAddress!, byteCount: size)
        }
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
    }

    /// Writes a block of data whose length is not known in advance, reserving a size prefix.
    /// The supplied closure is passed a mutable reference to the buffer immediately after
    /// the size prefix. The closure should perform writes and return the number of bytes written.
    /// After the block executes, the size prefix is updated to reflect the actual byte count written.
    ///
    /// - Parameter block: Closure that writes to the buffer and returns the byte count written.
    /// - Throws: `UnsafeCodableError` if writing fails.
    @inline(__always)
    public mutating func writeBlock(_ block: (_ buffer: inout Self) throws(UnsafeCodableError) -> UInt64) throws(UnsafeCodableError) {
        let sizePrefixPointer = self.ptr
        try self.write(value: UInt64(0))
        let count = try block(&self)
        sizePrefixPointer.assumingMemoryBound(to: UInt64.self).pointee = UInt64(count)
    }
}

