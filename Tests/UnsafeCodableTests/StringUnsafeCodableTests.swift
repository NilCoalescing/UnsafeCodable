import Testing
import Foundation
@testable import UnsafeCodable

@Suite("String UnsafeCodable Roundtrip")
struct StringUnsafeCodableRoundtripTests {
    @Test("String encode and decode roundtrip - random ASCII")
    func stringEncodeDecodeRandomASCII() async throws {
        let original = "Hello, World!"
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try String(from: &readPtr)
                #expect(decoded == original, "Decoded ASCII string should match original")
            }
        )
    }

    @Test("String encode and decode roundtrip - empty string")
    func stringEncodeDecodeEmpty() async throws {
        let original = ""
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try String(from: &readPtr)
                #expect(decoded == original, "Decoded empty string should match original")
            }
        )
    }

    @Test("String encode and decode roundtrip - Unicode characters")
    func stringEncodeDecodeUnicode() async throws {
        let original = "こんにちは世界🌏🚀"
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try String(from: &readPtr)
                #expect(decoded == original, "Decoded unicode string should match original")
            }
        )
    }

    @Test("String encode and decode roundtrip - repeating chars")
    func stringEncodeDecodeRepeating() async throws {
        let original = String(repeating: "A", count: 1024)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try String(from: &readPtr)
                #expect(decoded == original, "Decoded repeating string should match original")
            }
        )
    }

    @Test("String encode and decode roundtrip - emoji sequence")
    func stringEncodeDecodeEmojis() async throws {
        let original = "😀😃😄😁😆😅😂🤣😊😇"
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try String(from: &readPtr)
                #expect(decoded == original, "Decoded emoji string should match original")
            }
        )
    }
}
