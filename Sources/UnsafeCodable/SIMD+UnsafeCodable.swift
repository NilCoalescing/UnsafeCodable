//
//  SIMD+UnsafeCodable.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation
import simd

extension SIMD4: UnsafeCodable where Scalar: BitwiseCopyable {
    
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD4Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }
    
    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD4 scalar must be bitwise copyable")
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD4Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }
    
    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD4 scalar must be bitwise copyable")
    }
    
    
    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}

extension SIMD2: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD2Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD2 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD2Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD2 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}

extension SIMD3: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD4Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD3 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD4Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD3 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}

extension SIMD8: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD8Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD8 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD8Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD8 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}

extension SIMD16: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD16Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD16 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD16Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD16 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}


extension SIMD32: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD32Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD32 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD32Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD32 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}

extension SIMD64: UnsafeCodable where Scalar: BitwiseCopyable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }

    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) where Scalar.SIMD64Storage: BitwiseCopyable {
        self = try ptr.read(Self.self)
    }

    @_disfavoredOverload
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD64 scalar must be bitwise copyable")
    }

    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) where Scalar.SIMD64Storage: BitwiseCopyable {
        try ptr.write(value: self)
    }

    @_disfavoredOverload
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        fatalError("SIMD64 scalar must be bitwise copyable")
    }

    public var sizeInBytes: Int {
        MemoryLayout<Self>.stride
    }
}
