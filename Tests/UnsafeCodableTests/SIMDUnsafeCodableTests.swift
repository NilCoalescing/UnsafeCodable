import Testing
import simd
@testable import UnsafeCodable

@Suite("SIMD UnsafeCodable Roundtrip")
struct SIMDUnsafeCodableRoundtripTests {
    @Test("SIMD2 encode and decode roundtrip")
    func simd2EncodeDecode() async throws {
        let original = SIMD2<Double>(1.1, 2.2)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD2<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD2 decoded value should match original")
            }
        )
    }

    @Test("SIMD4 encode and decode roundtrip")
    func simd4EncodeDecode() async throws {
        let original = SIMD4<Double>(3.3, 4.4, 5.5, 6.6)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD4<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD4 decoded value should match original")
            }
        )
    }

    @Test("SIMD3 encode and decode roundtrip")
    func simd3EncodeDecode() async throws {
        let original = SIMD3<Double>(7.7, 8.8, 9.9)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD3<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD3 decoded value should match original")
            }
        )
    }

    @Test("SIMD8 encode and decode roundtrip")
    func simd8EncodeDecode() async throws {
        let original = SIMD8<Double>(1,2,3,4,5,6,7,8)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD8<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD8 decoded value should match original")
            }
        )
    }

    @Test("SIMD16 encode and decode roundtrip")
    func simd16EncodeDecode() async throws {
        let original = SIMD16<Double>(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD16<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD16 decoded value should match original")
            }
        )
    }

    @Test("SIMD32 encode and decode roundtrip")
    func simd32EncodeDecode() async throws {
        let original = SIMD32<Double>((0..<32).map { Double($0) })
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD32<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD32 decoded value should match original")
            }
        )
    }

    @Test("SIMD64 encode and decode roundtrip")
    func simd64EncodeDecode() async throws {
        let original = SIMD64<Double>((0..<64).map { Double($0) })
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try SIMD64<Double>(from: &readPtr)
                #expect(decoded == original, "SIMD64 decoded value should match original")
            }
        )
    }
}
