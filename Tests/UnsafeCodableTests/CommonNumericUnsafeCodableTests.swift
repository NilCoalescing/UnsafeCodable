import Testing
@testable import UnsafeCodable

@Suite("Common Numeric UnsafeCodable Roundtrip")
struct CommonNumericUnsafeCodableRoundtripTests {
    @Test("Int encode and decode roundtrip")
    func intEncodeDecode() async throws {
        let original: Int = 123456789
        try withBoundedBuffer(bufferSize: MemoryLayout<Int>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: original)
            },
            read: { readPtr in
                let decoded = try readPtr.read(Int.self)
                #expect(decoded == original, "Int decoded value should match original")
            }
        )
    }

    @Test("UInt encode and decode roundtrip")
    func uintEncodeDecode() async throws {
        let original: UInt = 987654321
        try withBoundedBuffer(bufferSize: MemoryLayout<UInt>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: original)
            },
            read: { readPtr in
                let decoded = try readPtr.read(UInt.self)
                #expect(decoded == original, "UInt decoded value should match original")
            }
        )
    }

    @Test("Float encode and decode roundtrip")
    func floatEncodeDecode() async throws {
        let original: Float = 123.456
        try withBoundedBuffer(bufferSize: MemoryLayout<Float>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: original)
            },
            read: { readPtr in
                let decoded = try readPtr.read(Float.self)
                #expect(decoded == original, "Float decoded value should match original")
            }
        )
    }

    @Test("Double encode and decode roundtrip")
    func doubleEncodeDecode() async throws {
        let original: Double = 789.012
        try withBoundedBuffer(bufferSize: MemoryLayout<Double>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: original)
            },
            read: { readPtr in
                let decoded = try readPtr.read(Double.self)
                #expect(decoded == original, "Double decoded value should match original")
            }
        )
    }

    @Test("Bool encode and decode roundtrip")
    func boolEncodeDecode() async throws {
        let originals: [Bool] = [true, false]
        for original in originals {
            try withBoundedBuffer(bufferSize: MemoryLayout<Bool>.size,
                write: { mutablePtr in
                    try mutablePtr.write(value: original)
                },
                read: { readPtr in
                    let decoded = try readPtr.read(Bool.self)
                    #expect(decoded == original, "Bool decoded value should match original")
                }
            )
        }
    }
}

