//
//  BoundedReadOnlyRawPointer.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

/// A pointer wrapper that allows safe, bounded, and read-only access to a memory region, enabling bitwise copyable reads and array reads with length tracking.
public struct BoundedReadOnlyRawPointer: ~Copyable {
    /// Remaining length, in bytes, that can be read from the pointer.
    public private(set) var length: Int
    /// The current raw pointer position for reading data.
    public private(set) var ptr: UnsafeRawPointer
    
    /// Initializes a bounded read-only raw pointer.
    /// - Parameters:
    ///   - length: The number of bytes available to read.
    ///   - ptr: The base raw pointer to read from.
    public init(length: Int, ptr: UnsafeRawPointer) {
        self.length = length
        self.ptr = ptr
    }
    
    /// Initializes from an UnsafeRawBufferPointer.
    /// - Parameter buffer: The raw buffer pointer to read from.
    public init(_ buffer: UnsafeRawBufferPointer) {
        self.length = buffer.count
        self.ptr = buffer.baseAddress ?? UnsafeRawPointer(bitPattern: 0)!
    }
    
    /// Initializes from an UnsafeBufferPointer<T>.
    /// - Parameter buffer: The typed buffer pointer to read from.
    public init<T>(_ buffer: UnsafeBufferPointer<T>) {
        self.length = MemoryLayout<T>.stride * buffer.count
        self.ptr = UnsafeRawPointer(buffer.baseAddress ?? UnsafePointer<T>(bitPattern: 0)!)
    }
    
    /// Reads a version byte from the pointer and asserts it equals a specific value.
    /// - Parameter value: The expected version byte.
    /// - Throws: `UnsafeCodableError.versionError` if the read version doesn't match.
    public mutating func assertVersion(_ value: UInt8) throws(UnsafeCodableError) {
        let version = try self.read(UInt8.self)
        guard version == value else {
            throw UnsafeCodableError.versionError(expected: value, read: version)
        }
    }
    
    /// Reads a value of type `T` from the pointer and advances the pointer.
    /// - Parameter type: The type to read, must conform to `BitwiseCopyable`.
    /// - Throws: `UnsafeCodableError.outOfBounds` or other read errors.
    /// - Returns: The read value.
    public mutating func read<T>(_ type: T.Type) throws(UnsafeCodableError) -> T where T: BitwiseCopyable {
        let size = MemoryLayout<T>.size
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        let value = self.ptr.assumingMemoryBound(to: T.self).pointee
        
        
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
        
        return value
    }
    
    /**
     Reads a specified number of bytes from the pointer and returns them as a Data object, advancing the pointer and reducing the remaining length accordingly.
     - Parameter size: The number of bytes to read from the pointer.
     - Throws: `UnsafeCodableError.outOfBounds` if there aren't enough bytes remaining to satisfy the read.
     - Returns: A Data instance containing the read bytes.
     */
    internal mutating func read(_ size: Int) throws(UnsafeCodableError) -> Data {
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        var data = Data(count: size)
        data.withUnsafeMutableBytes { targetPTR in
            targetPTR.baseAddress!.copyMemory(from: self.ptr, byteCount: size)
        }
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
        return data
    }
    
    
    /// Reads an array of `count` elements of type `T` from the pointer and advances the pointer.
    /// - Parameters:
    ///   - type: The element type, must conform to `BitwiseCopyable`.
    ///   - count: The number of elements to read.
    /// - Throws: `UnsafeCodableError` if the operation fails.
    /// - Returns: The array of read elements.
    public mutating func readArray<T>(of type: T.Type, with count: Int) throws(UnsafeCodableError) -> [T] where T: BitwiseCopyable {
        let size = MemoryLayout<T>.stride * count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        let array: [T]
        do {
            array = try Array<T>(unsafeUninitializedCapacity: count) { (buffer, initializedCount) in
                guard let baseAddress = buffer.baseAddress else {
                    throw UnsafeCodableError.unableToUnwrap
                }
                UnsafeMutableRawPointer(mutating: baseAddress).copyMemory(
                    from: self.ptr,
                    byteCount: size
                )
                initializedCount = count
            }
        } catch (let error as UnsafeCodableError) {
            throw error
        } catch {
            throw UnsafeCodableError.memoryError
        }
        
        self.length -= size
        self.ptr = self.ptr.advanced(by: size)
        
        return array
    }
    
    /// Reads a count-prefixed array of elements of type `T` from the pointer and advances the pointer.
    /// The count is read as an `Int` before reading the array data.
    /// - Parameter type: The element type, must conform to `BitwiseCopyable`.
    /// - Throws: `UnsafeCodableError` if the operation fails.
    /// - Returns: The array of read elements.
    public mutating func readArray<T>(of type: T.Type) throws(UnsafeCodableError) -> [T] where T: BitwiseCopyable {
        let count = try self.read(Int.self)
        let size = MemoryLayout<T>.stride * count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        let array: [T]
        do {
            array = try Array<T>(unsafeUninitializedCapacity: count) { (buffer, initializedCount) in
                guard let baseAddress = buffer.baseAddress else {
                    throw UnsafeCodableError.unableToUnwrap
                }
                UnsafeMutableRawPointer(mutating: baseAddress).copyMemory(
                    from: self.ptr,
                    byteCount: size
                )
                initializedCount = count
            }
        } catch (let error as UnsafeCodableError) {
            throw error
        } catch {
            throw UnsafeCodableError.memoryError
        }
        
        
        self.length -= size
        self.ptr = self.ptr.advanced(by: size)
        
        return array
    }
    
    /// Reads a count-prefixed block using a closure, passing an updated buffer and the count.
    /// The count is read as a `UInt64` before the closure is called.
    /// - Parameter block: A closure that receives the updated pointer and count for custom reads.
    /// - Throws: `UnsafeCodableError` if the operation fails.
    @inline(__always)
    public mutating func read(_ block: (_ buffer: inout Self, _ count: UInt64) throws(UnsafeCodableError) -> Void) throws(UnsafeCodableError) {
        let count = try self.read(UInt64.self)
        try block(&self, count)
    }
    
}

