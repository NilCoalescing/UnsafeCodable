//
//  Array+UnsafeCodable.swift
//  LoopingWalk
//
//  Created by Matthaus Woolard on 28/09/23.
//

import Foundation

extension Array: UnsafeCodable where Element: UnsafeCodable {
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public var sizeInBytes: Int {
        self.reduce(0, { $0 + $1.sizeInBytes }) + MemoryLayout<Int>.size
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        let count = try ptr.read(Int.self)
        self = Array<Element>()
        self.reserveCapacity(count)
        for _ in 0..<count {
            try self.append(Element(from: &ptr))
        }
    }
    
    public func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(value: self.count)
        for point in self {
            try point.encode(to: &ptr)
        }
    }
}
