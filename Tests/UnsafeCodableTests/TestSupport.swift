import Testing
import Foundation
@testable import UnsafeCodable

// MARK: - Buffer helpers

/// Provides a bounded *mutable* buffer for tests that only need to exercise the write side
/// (for example, to assert that writing past the end of the region throws).
///
/// Unlike `withBoundedBuffer`, this does not create a read pointer, so a `write` closure
/// that throws part-way through does not leave a half-initialised read step behind.
@discardableResult
@usableFromInline
func withMutableBuffer<T>(
    size: Int,
    _ body: (inout BoundedMutableRawPointer) throws -> T
) rethrows -> T {
    var buffer = [UInt8](repeating: 0, count: size)
    return try buffer.withUnsafeMutableBytes { rawBuffer in
        var mutablePtr = BoundedMutableRawPointer(consuming: rawBuffer)
        return try body(&mutablePtr)
    }
}

/// Runs a throwing operation and returns the thrown `UnsafeCodableError`, if any.
///
/// This keeps associated-value assertions in the error-path tests free of `do`/`catch`
/// boilerplate and avoids `rethrows`/typed-throws exhaustiveness subtleties at call sites.
@usableFromInline
func capturedError(_ body: () throws -> Void) -> UnsafeCodableError? {
    do {
        try body()
        return nil
    } catch let error as UnsafeCodableError {
        return error
    } catch {
        return nil
    }
}

/// Round-trips a single `BitwiseCopyable` value through a bounded buffer using the raw
/// `write(value:)` / `read(_:)` primitives and asserts the decoded value matches.
@usableFromInline
func roundtripRaw<T: BitwiseCopyable & Equatable>(_ value: T) throws {
    try withBoundedBuffer(
        bufferSize: MemoryLayout<T>.size,
        write: { mutablePtr in
            try mutablePtr.write(value: value)
        },
        read: { readPtr in
            let decoded = try readPtr.read(T.self)
            #expect(decoded == value, "Raw round-trip should preserve the value")
        }
    )
}

// MARK: - Fixtures

/// A value type whose `UnsafeCodable` conformance is hand-written and which contains a
/// non-`BitwiseCopyable` stored property (`String`). Used to exercise the element-wise
/// (disfavored) collection code paths and nested encoding.
struct Person: UnsafeCodable, Equatable, Hashable {
    static let UNSAFE_CODABLE_VERSION: UInt8 = 7

    var id: Int
    var name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        id = try ptr.read(Int.self)
        name = try String(from: &ptr)
    }

    func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try ptr.write(value: id)
        try name.encode(to: &ptr)
    }

    var sizeInBytes: Int {
        MemoryLayout<UInt8>.size + MemoryLayout<Int>.size + name.sizeInBytes
    }
}

/// A plain `BitwiseCopyable` aggregate with no hand-written `UnsafeCodable` members.
/// Its entire conformance comes from the default `UnsafeCodable where Self: BitwiseCopyable`
/// extension, so it exercises that path (version 0, whole-value read/write).
struct RawPoint: UnsafeCodable, BitwiseCopyable, Equatable {
    var x: Int32
    var y: Int32
}
