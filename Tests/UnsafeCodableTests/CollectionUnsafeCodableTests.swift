import Testing
import Foundation
@testable import UnsafeCodable

@Suite("Set UnsafeCodable Roundtrip")
struct SetUnsafeCodableTests {

    @Test("Set<Int> round-trips via the fast (BitwiseCopyable) path")
    func setOfIntFastPath() throws {
        let original: Set<Int> = [1, 2, 3, 100, -50, .max, .min]
        try withBoundedBuffer(
            bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try Set<Int>(from: &readPtr)
                #expect(decoded == original)
            }
        )
    }

    @Test("Set<Int> round-trips through the Data API")
    func setOfIntViaDataAPI() throws {
        let original: Set<Int> = [7, 8, 9, -1, 0]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: Set<Int>.self)
        #expect(decoded == original)
    }

    @Test("Set<String> round-trips via the element-wise path")
    func setOfStringElementWise() throws {
        let original: Set<String> = ["alpha", "beta", "gamma", "δ", ""]
        // Serialized layout: Int count prefix, then each element as Int length + UTF-8 bytes.
        let exactSize = MemoryLayout<Int>.size
            + original.reduce(0) { $0 + MemoryLayout<Int>.size + $1.utf8.count }
        try withBoundedBuffer(
            bufferSize: exactSize,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try Set<String>(from: &readPtr)
                #expect(decoded == original)
            }
        )
    }

    @Test("Empty Set round-trips")
    func emptySet() throws {
        let original: Set<Int> = []
        let decoded = try Data(encoding: original).unsafelyDecoding(as: Set<Int>.self)
        #expect(decoded == original)
        #expect(decoded.isEmpty)
    }
}

@Suite("Dictionary UnsafeCodable Roundtrip")
struct DictionaryUnsafeCodableTests {

    @Test("[String: Int] round-trips through the Data API")
    func stringIntDictionary() throws {
        let original: [String: Int] = ["one": 1, "two": 2, "three": 3, "": 0]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [String: Int].self)
        #expect(decoded == original)
    }

    @Test("[Int: Person] round-trips through the Data API")
    func intPersonDictionary() throws {
        let original: [Int: Person] = [
            1: Person(id: 1, name: "Ada"),
            2: Person(id: 2, name: "Grace Hopper"),
            3: Person(id: 3, name: ""),
        ]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [Int: Person].self)
        #expect(decoded == original)
    }

    @Test("Decoding a dictionary with the wrong version byte throws .versionError")
    func dictionaryVersionMismatch() throws {
        // A dictionary stream begins with a version byte (expected 0) followed by an Int count.
        try withBoundedBuffer(
            bufferSize: MemoryLayout<UInt8>.size + MemoryLayout<Int>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: UInt8(99)) // wrong version
                try mutablePtr.write(value: Int(0))    // count
            },
            read: { readPtr in
                let error = capturedError { _ = try [String: Int](from: &readPtr) }
                guard case .versionError(let expected, let read)? = error else {
                    #expect(Bool(false), "Expected .versionError, got \(String(describing: error))")
                    return
                }
                #expect(expected == 0)
                #expect(read == 99)
            }
        )
    }

    @Test("Empty dictionary round-trips")
    func emptyDictionary() throws {
        let original: [String: Int] = [:]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [String: Int].self)
        #expect(decoded == original)
        #expect(decoded.isEmpty)
    }
}

@Suite("Array of non-bitwise elements Roundtrip")
struct ArrayElementWiseUnsafeCodableTests {

    @Test("[String] round-trips through the Data API")
    func stringArray() throws {
        let original = ["", "a", "a longer string", "δ漢字", "🚀"]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [String].self)
        #expect(decoded == original)
    }

    @Test("[Person] round-trips through the Data API")
    func personArray() throws {
        let original = [
            Person(id: 1, name: "a"),
            Person(id: 2, name: "bb"),
            Person(id: 3, name: ""),
            Person(id: -4, name: "with spaces"),
        ]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [Person].self)
        #expect(decoded == original)
    }

    @Test("Empty [String] round-trips")
    func emptyStringArray() throws {
        let original: [String] = []
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [String].self)
        #expect(decoded == original)
        #expect(decoded.isEmpty)
    }

    @Test("Nested [[Int]] round-trips through the Data API")
    func nestedIntArray() throws {
        let original = [[1, 2, 3], [], [4], [5, 6]]
        let decoded = try Data(encoding: original).unsafelyDecoding(as: [[Int]].self)
        #expect(decoded == original)
    }
}
