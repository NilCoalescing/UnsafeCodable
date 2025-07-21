import Testing
import Foundation
@testable import UnsafeCodable

@Suite("UUID UnsafeCodable Roundtrip")
struct UUIDUnsafeCodableRoundtripTests {

    @Test("UUID encode and decode roundtrip - random UUID")
    func uuidEncodeDecodeRandom() async throws {
        let original = UUID()
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try UUID(from: &readPtr)
                #expect(decoded == original, "UUID decoded value should match original")
            }
        )
    }

    @Test("UUID encode and decode roundtrip - all zeros")
    func uuidEncodeDecodeZeros() async throws {
        let original = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try UUID(from: &readPtr)
                #expect(decoded == original, "Zero UUID decoded value should match original")
            }
        )
    }

    @Test("UUID encode and decode roundtrip - all ones")
    func uuidEncodeDecodeOnes() async throws {
        let original = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try UUID(from: &readPtr)
                #expect(decoded == original, "Ones UUID decoded value should match original")
            }
        )
    }

    @Test("UUID encode and decode roundtrip - mixed pattern")
    func uuidEncodeDecodeMixed() async throws {
        let original = UUID(uuidString: "deadbeef-1234-5678-9abc-def012345678")!
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try UUID(from: &readPtr)
                #expect(decoded == original, "Mixed UUID decoded value should match original")
            }
        )
    }
}
