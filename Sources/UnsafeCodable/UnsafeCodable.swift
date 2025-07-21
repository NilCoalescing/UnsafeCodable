import Foundation


/// A protocol for types that support custom, potentially unsafe, encoding and decoding
/// to and from raw pointers. Used for high-performance serialization where memory safety
/// is managed externally.
public protocol UnsafeCodable {
    /// The version number of the encoding/decoding implementation for this type.
    /// Used to support migration and compatibility.
    static var UNSAFE_CODABLE_VERSION: UInt8 { get }
    
    /// Initializes an instance of the conforming type by decoding from a bounded, read-only raw pointer.
    /// - Parameter ptr: The pointer to decode from. Will be advanced by the amount consumed.
    /// - Throws: An `UnsafeCodableError` if decoding fails.
    init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError)
    
    /// Encodes the instance into a bounded, mutable raw pointer.
    /// - Parameter ptr: The pointer to encode into. Will be advanced by the amount written.
    /// - Throws: An `UnsafeCodableError` if encoding fails.
    func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError)
    
    /// The size in bytes required to encode this instance.
    var sizeInBytes: Int { get }
    
    /// The maximum possible byte size required to encode this instance.
    /// By default, returns the same value as `sizeInBytes`.
    var maximumSizeInBytes: Int { get }
}


/// Default implementations and convenience overloads for `UnsafeCodable`.
public extension UnsafeCodable {
    /// Initializes by consuming a read-only pointer, forwarding to the inout variant.
    init(from ptr: consuming BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        try self.init(from: &ptr)
    }
    
    /// Encodes by consuming a mutable pointer, forwarding to the inout variant.
    func encode(to ptr: consuming BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try self.encode(to: &ptr)
    }
    
    /// By default, returns `sizeInBytes` as the maximum size.
    var maximumSizeInBytes: Int {
        sizeInBytes
    }
}

extension UnsafeCodable where Self: BitwiseCopyable {
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
