import Testing
import Foundation
@testable import UnsafeCodable

@Suite("Bounds checking & error paths")
struct BoundsCheckingTests {

    // MARK: write bounds

    @Test("Writing a value into a too-small buffer throws .outOfBounds")
    func writeValueOutOfBounds() {
        withMutableBuffer(size: 4) { mutablePtr in
            let error = capturedError { try mutablePtr.write(value: Int(123)) } // needs 8 bytes
            guard case .outOfBounds(let requested, let remaining)? = error else {
                #expect(Bool(false), "Expected .outOfBounds, got \(String(describing: error))")
                return
            }
            #expect(requested == MemoryLayout<Int>.size)
            #expect(remaining == 4)
        }
    }

    @Test("Writing a count-prefixed array into a too-small buffer throws")
    func writeArrayOutOfBounds() {
        withMutableBuffer(size: 4) { mutablePtr in
            #expect(throws: UnsafeCodableError.self) {
                try mutablePtr.write(array: [1, 2, 3, 4, 5] as [Int])
            }
        }
    }

    // MARK: read bounds

    @Test("Reading past the end of the region throws .outOfBounds")
    func readValueOutOfBounds() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Int>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: Int(5))
            },
            read: { readPtr in
                _ = try readPtr.read(Int.self) // consumes everything, length now 0
                let error = capturedError { _ = try readPtr.read(UInt8.self) }
                guard case .outOfBounds(let requested, let remaining)? = error else {
                    #expect(Bool(false), "Expected .outOfBounds, got \(String(describing: error))")
                    return
                }
                #expect(requested == MemoryLayout<UInt8>.size)
                #expect(remaining == 0)
            }
        )
    }

    @Test("Decoding an array whose count prefix exceeds the data throws")
    func readArrayTruncated() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Int>.size * 3,
            write: { mutablePtr in
                try mutablePtr.write(value: Int(1000)) // claim 1000 elements
                try mutablePtr.write(value: Int(7))     // ...but only provide one
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try readPtr.readArray(of: Int.self)
                }
            }
        )
    }

    @Test("Decoding a String whose length prefix exceeds the data throws")
    func readStringTruncated() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Int>.size + 4,
            write: { mutablePtr in
                try mutablePtr.write(value: Int(1000)) // claim 1000 UTF-8 bytes
                try mutablePtr.write(value: UInt8(65))  // ...but only provide one
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try String(from: &readPtr)
                }
            }
        )
    }

    // MARK: version errors

    @Test("assertVersion succeeds when the version matches")
    func assertVersionMatches() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<UInt8>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: UInt8(3))
            },
            read: { readPtr in
                // Should not throw.
                try readPtr.assertVersion(3)
            }
        )
    }

    @Test("assertVersion throws .versionError on mismatch")
    func assertVersionMismatch() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<UInt8>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: UInt8(5))
            },
            read: { readPtr in
                let error = capturedError { try readPtr.assertVersion(9) }
                guard case .versionError(let expected, let read)? = error else {
                    #expect(Bool(false), "Expected .versionError, got \(String(describing: error))")
                    return
                }
                #expect(expected == 9)
                #expect(read == 5)
            }
        )
    }

    // MARK: pointer state tracking

    @Test("Mutable and read pointers track remaining length as bytes are consumed")
    func lengthTracking() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Int32>.size * 3,
            write: { mutablePtr in
                #expect(mutablePtr.length == 12)
                try mutablePtr.write(value: Int32(7))
                #expect(mutablePtr.length == 8)
                try mutablePtr.write(value: Int32(8))
                #expect(mutablePtr.length == 4)
                try mutablePtr.write(value: Int32(9))
                #expect(mutablePtr.length == 0)
            },
            read: { readPtr in
                #expect(readPtr.length == 12)
                _ = try readPtr.read(Int32.self)
                #expect(readPtr.length == 8)
                _ = try readPtr.read(Int32.self)
                #expect(readPtr.length == 4)
                _ = try readPtr.read(Int32.self)
                #expect(readPtr.length == 0)
            }
        )
    }
}
