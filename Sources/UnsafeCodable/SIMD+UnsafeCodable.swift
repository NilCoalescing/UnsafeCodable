//
//  SIMD+UnsafeCodable.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

extension SIMD4: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        self = try ptr.read(Self.self)
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: self)
    }
    
    public var sizeInBytes: Int {
        MemoryLayout<Self>.size
    }
}

extension SIMD2: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        self = try ptr.read(Self.self)
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: self)
    }
    
    public var sizeInBytes: Int {
        MemoryLayout<Self>.size
    }
}
