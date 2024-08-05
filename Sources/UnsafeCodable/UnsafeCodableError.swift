//
//  UnsafeCodableError.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

public enum UnsafeCodableError: Error, LocalizedError {
    case outOfBounds(requested: Int, remaining: Int)
    case versionError(expected: UInt8, read: UInt8)
    case unableToUnwrap
    case memoryError
    
    public var errorDescription: String? {
        switch self {
        case .outOfBounds(requested: let requested, remaining: let remaining):
            "Unsafe Codable: Out of bounds requested \(requested) remaining \(remaining)"
        case .versionError(expected: let expected, read: let read):
            "Unsafe Codable: Version expected \(expected) found \(read)"
        case .unableToUnwrap:
            "Unsafe Codable: unable to unwrap pointer"
        case .memoryError:
            "Unsafe Codable: Memory errror"
        }
    }
}
