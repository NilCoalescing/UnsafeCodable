//
//  Data+UnsafeCodable.swift
//  UnsafeCodable
//
//  Created by Matthaus Woolard on 21/07/2025.
//
import Foundation

extension Data {
    func unsafelyDecoding<T>(as targetType: T.Type) throws -> T where T: UnsafeCodable {
        return try self.withUnsafeBytes { ptr in
            var boundedPtr = BoundedReadOnlyRawPointer(ptr)
            return try T(from: &boundedPtr)
        }
    }
    
    init<T>(encoding: T) throws where T: UnsafeCodable {
        let size = encoding.maximumSizeInBytes
        self.init(count: size)
        try self.withUnsafeMutableBytes { ptr in
            var bounded = BoundedMutableRawPointer(consuming: ptr)
            try encoding.encode(to: &bounded)
        }
    }
}

extension Data: UnsafeCodable {
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: self.count)
        try ptr.write(self)
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        let size = try ptr.read(Int.self)
        self = try ptr.read(size)
    }
    
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public var sizeInBytes: Int {
        self.count + MemoryLayout<Int>.size
    }
}
