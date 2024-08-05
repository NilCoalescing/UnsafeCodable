//
//  UUID+UnsafeCodable.swift
//  Strolly
//
//  Created by Matthaus Woolard on 10/06/2024.
//

import Foundation

extension UUID: UnsafeCodable {
    public func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(value: self.uuid)
    }
    
    public init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        let uuid = try ptr.read(uuid_t.self)
        self.init(uuid: uuid)
    }
    
    public static var UNSAFE_CODABLE_VERSION: UInt8 {
        0
    }
    
    public var sizeInBytes: Int {
        MemoryLayout<uuid_t>.size
    }
}
