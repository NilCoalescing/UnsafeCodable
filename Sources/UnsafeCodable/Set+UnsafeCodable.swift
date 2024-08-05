//
//  Set+UnsafeCodable.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

extension Set<Int>: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        self = Set(try ptr.readArray(of: Element.self))
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(array: Array(self))
    }
    
    public var sizeInBytes: Int {
        self.count * MemoryLayout<Element>.stride + MemoryLayout<Int>.size
    }
}
