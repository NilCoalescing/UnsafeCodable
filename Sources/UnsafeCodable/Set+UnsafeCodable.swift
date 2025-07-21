//
//  Set+UnsafeCodable.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

extension Set: UnsafeCodable where Element: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Element: BitwiseCopyable {
        self = Set(try ptr.readArray(of: Element.self))
    }
    
    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        let elements = try Array<Element>(from: &ptr)
        self = Set(elements)
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Element: BitwiseCopyable {
        try ptr.write(array: Array(self))
    }
    
    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        let array = Array(self)
        try array.encode(to: &ptr)
    }
    
    public var sizeInBytes: Int {
        self.count * MemoryLayout<Element>.stride + MemoryLayout<Int>.size
    }
}
