import Testing
@testable import UnsafeCodable

@Suite("Array Numeric UnsafeCodable Roundtrip")
struct ArrayNumericUnsafeCodableRoundtripTests {
    @Test("[Int] encode and decode roundtrip")
    func intArrayEncodeDecode() async throws {
        let original: [Int] = [1, 2, 3, 4, 5]
        try withBoundedBuffer(bufferSize: MemoryLayout<Int>.size * original.count + MemoryLayout<Int>.size,
            write: { mutablePtr in
                try mutablePtr.write(array: original)
            },
            read: { readPtr in
                let decoded = try readPtr.readArray(of: Int.self)
                #expect(decoded == original, "Decoded Int array should match original")
            }
        )
    }

    @Test("[Float] encode and decode roundtrip")
    func floatArrayEncodeDecode() async throws {
        let original: [Float] = [1.5, 2.5, 3.5, 4.5]
        try withBoundedBuffer(bufferSize: MemoryLayout<Float>.size * original.count + MemoryLayout<Int>.size,
            write: { mutablePtr in
                try mutablePtr.write(array: original)
            },
            read: { readPtr in
                let decoded = try readPtr.readArray(of: Float.self)
                #expect(decoded == original, "Decoded Float array should match original")
            }
        )
    }
}
