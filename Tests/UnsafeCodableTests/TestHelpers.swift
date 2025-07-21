import Foundation
import UnsafeCodable

/// Provides a bounded buffer for encoding and decoding binary data in tests.
@discardableResult
@usableFromInline
func withBoundedBuffer<T>(bufferSize: Int, write: (inout BoundedMutableRawPointer) throws -> Void, read: (inout BoundedReadOnlyRawPointer) throws -> T) rethrows -> T {
    var buffer = [UInt8](repeating: 0, count: bufferSize)
    return try buffer.withUnsafeMutableBytes { rawBuffer in
        var mutablePtr = BoundedMutableRawPointer(consuming: rawBuffer)
        try write(&mutablePtr)
        var readPtr = BoundedReadOnlyRawPointer(length: bufferSize, ptr: UnsafeRawPointer(rawBuffer.baseAddress!))
        return try read(&readPtr)
    }
}
