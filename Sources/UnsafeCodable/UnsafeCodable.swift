
import Foundation


public protocol UnsafeCodable {
    static var UNSAFE_CODABLE_VERSION: UInt8 { get }
    init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError)
    func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError)
    var sizeInBytes: Int { get }
    var maximumSizeInBytes: Int { get }
}

public extension UnsafeCodable {
    init(from ptr: consuming BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        try self.init(from: &ptr)
    }
    
    func encode(to ptr: consuming BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try self.encode(to: &ptr)
    }
    
    var maximumSizeInBytes: Int {
        sizeInBytes
    }
}
