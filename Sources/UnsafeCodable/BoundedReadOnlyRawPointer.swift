//
//  BoundedReadOnlyRawPointer.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

public struct BoundedReadOnlyRawPointer: ~Copyable {
    public private(set) var length: Int
    public private(set) var ptr: UnsafeRawPointer
    
    public init(length: Int, ptr: UnsafeRawPointer) {
        self.length = length
        self.ptr = ptr
    }
    
    public mutating func assertVersion(_ value: UInt8) throws {
        let version = try self.read(UInt8.self)
        guard version == value else {
            throw UnsafeCodableError.versionError(expected: value, read: version)
        }
    }
    
    public mutating func read<T>(_ type: T.Type) throws -> T {
        let size = MemoryLayout<T>.size
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        let value = self.ptr.assumingMemoryBound(to: T.self).pointee
        
        
        self.ptr = self.ptr.advanced(by: size)
        self.length -= size
        
        return value
    }
    
    
    public mutating func readArray<T>(of type: T.Type, with count: Int) throws -> [T] {
        let size = MemoryLayout<T>.stride * count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        let array = try Array<T>(unsafeUninitializedCapacity: count) { (buffer, initializedCount) in
            guard let baseAddress = buffer.baseAddress else {
                throw UnsafeCodableError.unableToUnwrap
            }
            UnsafeMutableRawPointer(mutating: baseAddress).copyMemory(
                from: self.ptr,
                byteCount: size
            )
            initializedCount = count
        }
        self.length -= size
        self.ptr = self.ptr.advanced(by: size)
        
        return array
    }
    
    public mutating func readArray<T>(of type: T.Type) throws -> [T] {
        let count = try self.read(Int.self)
        let size = MemoryLayout<T>.stride * count
        guard length >= size else {
            throw UnsafeCodableError.outOfBounds(requested: size, remaining: length)
        }
        
        let array = try Array<T>(unsafeUninitializedCapacity: count) { (buffer, initializedCount) in
            guard let baseAddress = buffer.baseAddress else {
                throw UnsafeCodableError.unableToUnwrap
            }
            UnsafeMutableRawPointer(mutating: baseAddress).copyMemory(
                from: self.ptr,
                byteCount: size
            )
            initializedCount = count
        }
        self.length -= size
        self.ptr = self.ptr.advanced(by: size)
        
        return array
    }
    
    @inline(__always)
    public mutating func read(_ block: (_ buffer: inout Self, _ count: UInt64) throws -> Void) throws {
        let count = try self.read(UInt64.self)
        try block(&self, count)
    }
    
}
