//
//  Array+UnsafeCodable.swift
//  LoopingWalk
//
//  Created by Matthaus Woolard on 28/09/23.
//

import Foundation

/// Extension to make Array conform to UnsafeCodable when its elements do.
extension Array: UnsafeCodable where Element: UnsafeCodable {
    /// The version of the UnsafeCodable implementation for Array.
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    /// Returns the total size in bytes needed to encode this array, including element sizes and array count.
    @inlinable
    public var sizeInBytes: Int {
        self._sizeInBytes()
    }
    
    /// Optimized size computation for arrays of BitwiseCopyable elements
    @inlinable
    internal func _sizeInBytes() -> Int where Element: BitwiseCopyable {
        self.count * MemoryLayout<Element>.stride + MemoryLayout<Int>.size
    }
    
    @_disfavoredOverload
    @inlinable
    internal func _sizeInBytes() -> Int {
        self.reduce(0, { $0 + $1.sizeInBytes }) + MemoryLayout<Int>.size
    }
    
    /// Optimized decoding for arrays of BitwiseCopyable elements
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Element: BitwiseCopyable {
        self = try ptr.readArray(of: Element.self)
    }
    
    /// Initializes an Array by decoding its elements from the provided bounded read-only raw pointer.
    /// - Parameter ptr: The bounded read-only pointer from which to decode the array.
    /// - Throws: UnsafeCodableError if decoding fails.
    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        let count = try ptr.read(Int.self)
        self = Array<Element>()
        self.reserveCapacity(count)
        for _ in 0..<count {
            try self.append(Element(from: &ptr))
        }
    }
    
    /// Encodes this array and its elements into the provided bounded mutable raw pointer.
    /// - Parameter ptr: The bounded mutable pointer to which the array will be encoded.
    /// - Throws: UnsafeCodableError if encoding fails.
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Element: BitwiseCopyable {
        try ptr.write(array: self)
    }
    
    /// Encodes this array and its elements into the provided bounded mutable raw pointer.
    /// - Parameter ptr: The bounded mutable pointer to which the array will be encoded.
    /// - Throws: UnsafeCodableError if encoding fails.
    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: self.count)
        for point in self {
            try point.encode(to: &ptr)
        }
    }
}
