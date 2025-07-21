//
//  String+UnsafeCodable.swift
//  LoopingWalk
//
//  Created by Swift Assistant on 2025-07-21.
//

import Foundation

extension String: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 { 0 }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        let bytes = try ptr.readArray(of: String.UTF8View.Element.self)
        guard let str = String(bytes: bytes, encoding: .utf8) else {
            throw UnsafeCodableError.memoryError
        }
        self = str
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        let bytes = Array(self.utf8)
        try ptr.write(array: bytes)
    }
    
    public var sizeInBytes: Int {
        return MemoryLayout<Int>.size + self.utf8.count * MemoryLayout<String.UTF8View.Element>.stride
    }
}
