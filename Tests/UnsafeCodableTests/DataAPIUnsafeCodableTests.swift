import Testing
import Foundation
@testable import UnsafeCodable

/// Exercises the primary public entry points documented in the README:
/// `Data(encoding:)` and `Data.unsafelyDecoding(as:)`.
@Suite("Data public API")
struct DataAPITests {

    @Test("Data(encoding:) / unsafelyDecoding round-trips a scalar")
    func scalarRoundtrip() throws {
        let original = 123_456_789
        let data = try Data(encoding: original)
        let decoded = try data.unsafelyDecoding(as: Int.self)
        #expect(decoded == original)
    }

    @Test("Data(encoding:) produces maximumSizeInBytes bytes")
    func encodingProducesExpectedSize() throws {
        let value = RawPoint(x: 1, y: 2)
        let data = try Data(encoding: value)
        #expect(data.count == value.maximumSizeInBytes)
    }

    @Test("Data API round-trips a value type with a nested String")
    func personRoundtrip() throws {
        let original = Person(id: 42, name: "Ada Lovelace")
        let decoded = try Data(encoding: original).unsafelyDecoding(as: Person.self)
        #expect(decoded == original)
    }

    @Test("Data API round-trips a String")
    func stringRoundtrip() throws {
        let original = "Hello, UnsafeCodable 🌏"
        let decoded = try Data(encoding: original).unsafelyDecoding(as: String.self)
        #expect(decoded == original)
    }

    // MARK: Data: UnsafeCodable conformance

    @Test("Data conforms to UnsafeCodable and round-trips its bytes")
    func dataConformanceRoundtrip() throws {
        let original = Data([0, 1, 2, 3, 127, 128, 255])
        try withBoundedBuffer(
            bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try Data(from: &readPtr)
                #expect(decoded == original)
            }
        )
    }

    // NOTE: An empty-`Data` round-trip is intentionally NOT tested here. `Data`'s
    // `encode`/`init(from:)` reach `BoundedMutableRawPointer.write(_ data:)` and
    // `BoundedReadOnlyRawPointer.read(_ size:)`, which force-unwrap `baseAddress` on a
    // zero-length `Data`. That traps (crashes the process) rather than throwing, so a
    // test would abort the whole run instead of failing cleanly. Worth fixing in the
    // library (guard the empty case) and then adding the test.

    @Test("Nested Data round-trips through the convenience API")
    func nestedDataRoundtrip() throws {
        let original = Data((0..<256).map { UInt8($0) })
        let decoded = try Data(encoding: original).unsafelyDecoding(as: Data.self)
        #expect(decoded == original)
    }
}
