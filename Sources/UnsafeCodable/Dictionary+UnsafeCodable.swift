//
//  Dictionary+UnsafeCodable.swift
//  LoopingWalk
//
//  Created by Matthaus Woolard on 2/10/23.
//

import Foundation

extension Dictionary: UnsafeCodable where Key: UnsafeCodable, Value: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 { 0 }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        self = [:]
        let count = try ptr.read(Int.self)
        for _ in 0..<count {
            let index = try Key(from: &ptr)
            let value = try Value(from: &ptr)
            self[index] = value
        }
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try ptr.write(value: self.count)
        for (index, value) in self {
            try index.encode(to: &ptr)
            try value.encode(to: &ptr)
        }
    }
    
    public var sizeInBytes: Int {
        self.reduce(0) { (partialResult, valueSet) in
            partialResult + valueSet.key.sizeInBytes + valueSet.value.sizeInBytes
        } + MemoryLayout<Int>.size + MemoryLayout<UInt8>.size
    }
}
