import Testing
import Foundation
@testable import UnsafeCodable

@Suite("Block writes & fixed-count arrays")
struct BlockAndFixedArrayTests {

    @Test("writeBlock / read(block:) round-trips a size-prefixed sequence")
    func blockRoundtrip() throws {
        let values: [Int] = [10, 20, 30, 40]
        let bufferSize = MemoryLayout<UInt64>.size + values.count * MemoryLayout<Int>.size
        try withBoundedBuffer(
            bufferSize: bufferSize,
            write: { mutablePtr in
                try mutablePtr.writeBlock { (inner: inout BoundedMutableRawPointer) throws(UnsafeCodableError) -> UInt64 in
                    for value in values {
                        try inner.write(value: value)
                    }
                    return UInt64(values.count)
                }
            },
            read: { readPtr in
                var decoded: [Int] = []
                try readPtr.read { (inner: inout BoundedReadOnlyRawPointer, count: UInt64) throws(UnsafeCodableError) -> Void in
                    for _ in 0..<count {
                        decoded.append(try inner.read(Int.self))
                    }
                }
                #expect(decoded == values)
            }
        )
    }

    @Test("writeBlock patches the size prefix with the value the block returns")
    func writeBlockPatchesPrefix() throws {
        let bufferSize = MemoryLayout<UInt64>.size + MemoryLayout<Int>.size
        try withBoundedBuffer(
            bufferSize: bufferSize,
            write: { mutablePtr in
                try mutablePtr.writeBlock { (inner: inout BoundedMutableRawPointer) throws(UnsafeCodableError) -> UInt64 in
                    try inner.write(value: Int(999))
                    return 42 // arbitrary "count" stored in the prefix
                }
            },
            read: { readPtr in
                let prefix = try readPtr.read(UInt64.self)
                #expect(prefix == 42)
                let payload = try readPtr.read(Int.self)
                #expect(payload == 999)
            }
        )
    }

    @Test("readArray(of:with:) reads a fixed count with no length prefix")
    func readArrayFixedCount() throws {
        let values: [Int32] = [1, 2, 3, 4, 5]
        let bufferSize = values.count * MemoryLayout<Int32>.stride
        try withBoundedBuffer(
            bufferSize: bufferSize,
            write: { mutablePtr in
                for value in values {
                    try mutablePtr.write(value: value) // raw elements, no count prefix
                }
            },
            read: { readPtr in
                let decoded = try readPtr.readArray(of: Int32.self, with: values.count)
                #expect(decoded == values)
            }
        )
    }

    @Test("readArray(of:with:) throws when the fixed count exceeds the data")
    func readArrayFixedCountOutOfBounds() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Int32>.size * 2,
            write: { mutablePtr in
                try mutablePtr.write(value: Int32(1))
                try mutablePtr.write(value: Int32(2))
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try readPtr.readArray(of: Int32.self, with: 100)
                }
            }
        )
    }
}
