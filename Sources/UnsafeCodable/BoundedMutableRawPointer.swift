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
    
    public init(length: Int, ptr: UnsafeMutableRawPointer) {
        self.length = length
        self.ptr = ptr
    }
    
    public mutating func write<T>(value: T) throws(UnsafeCodableError) where T: Copyable {
        let size = MemoryLayout<T>.size
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        self.ptr.assumingMemoryBound(to: T.self).pointee = value
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
    }
    
    public mutating func write<T>(array: [T]) throws(UnsafeCodableError) {
        try self.write(value: array.count)
        try self.writeRaw(array: array)
    }
    
    
    private mutating func writeRaw<T>(array: [T]) throws(UnsafeCodableError) {
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

    @inline(__always)
    public mutating func writeBlock(_ block: (_ buffer: inout Self) throws(UnsafeCodableError) -> UInt64) throws(UnsafeCodableError) {
        let sizePrefixPointer = self.ptr
        try self.write(value: UInt64(0))
        let count = try block(&self)
        sizePrefixPointer.assumingMemoryBound(to: UInt64.self).pointee = UInt64(count)
    }
}
