import Testing
import Foundation
@testable import UnsafeCodable

@Suite("Numeric edge cases")
struct NumericEdgeCaseTests {

    // MARK: signed integers at their extremes

    @Test("Int8 edges", arguments: [Int8.min, -1, 0, 1, Int8.max])
    func int8(_ value: Int8) throws { try roundtripRaw(value) }

    @Test("Int16 edges", arguments: [Int16.min, -1, 0, 1, Int16.max])
    func int16(_ value: Int16) throws { try roundtripRaw(value) }

    @Test("Int32 edges", arguments: [Int32.min, -1, 0, 1, Int32.max])
    func int32(_ value: Int32) throws { try roundtripRaw(value) }

    @Test("Int64 edges", arguments: [Int64.min, -1, 0, 1, Int64.max])
    func int64(_ value: Int64) throws { try roundtripRaw(value) }

    @Test("Int edges", arguments: [Int.min, -1, 0, 1, Int.max])
    func int(_ value: Int) throws { try roundtripRaw(value) }

    // MARK: unsigned integers at their extremes

    @Test("UInt8 edges", arguments: [UInt8.min, 1, UInt8.max])
    func uint8(_ value: UInt8) throws { try roundtripRaw(value) }

    @Test("UInt16 edges", arguments: [UInt16.min, 1, UInt16.max])
    func uint16(_ value: UInt16) throws { try roundtripRaw(value) }

    @Test("UInt32 edges", arguments: [UInt32.min, 1, UInt32.max])
    func uint32(_ value: UInt32) throws { try roundtripRaw(value) }

    @Test("UInt64 edges", arguments: [UInt64.min, 1, UInt64.max])
    func uint64(_ value: UInt64) throws { try roundtripRaw(value) }

    @Test("UInt edges", arguments: [UInt.min, 1, UInt.max])
    func uint(_ value: UInt) throws { try roundtripRaw(value) }

    // MARK: scalars through the public Data API at their extremes

    @Test("Int round-trips through the Data API at its extremes",
          arguments: [Int.min, -1, 0, 1, Int.max])
    func intViaDataAPI(_ value: Int) throws {
        let decoded = try Data(encoding: value).unsafelyDecoding(as: Int.self)
        #expect(decoded == value)
    }

    // MARK: floating point

    @Test("Double finite/infinite specials",
          arguments: [
            Double.greatestFiniteMagnitude,
            -Double.greatestFiniteMagnitude,
            .leastNonzeroMagnitude,
            .infinity,
            -.infinity,
            .pi,
            0.0,
          ])
    func doubleSpecials(_ value: Double) throws { try roundtripRaw(value) }

    @Test("Float finite/infinite specials",
          arguments: [
            Float.greatestFiniteMagnitude,
            -Float.greatestFiniteMagnitude,
            .leastNonzeroMagnitude,
            .infinity,
            -.infinity,
            .pi,
            0.0,
          ])
    func floatSpecials(_ value: Float) throws { try roundtripRaw(value) }

    @Test("Double NaN round-trips as NaN")
    func doubleNaN() throws {
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Double>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: Double.nan)
            },
            read: { readPtr in
                let decoded = try readPtr.read(Double.self)
                #expect(decoded.isNaN)
            }
        )
    }

    @Test("Signed zero preserves its bit pattern")
    func negativeZero() throws {
        let original = -0.0 as Double
        try withBoundedBuffer(
            bufferSize: MemoryLayout<Double>.size,
            write: { mutablePtr in
                try mutablePtr.write(value: original)
            },
            read: { readPtr in
                let decoded = try readPtr.read(Double.self)
                #expect(decoded.bitPattern == original.bitPattern)
            }
        )
    }

    // MARK: default conformance for BitwiseCopyable aggregates

    @Test("A BitwiseCopyable struct gets a working default UnsafeCodable conformance")
    func defaultBitwiseConformance() throws {
        #expect(RawPoint.UNSAFE_CODABLE_VERSION == 0)

        let value = RawPoint(x: 3, y: -7)
        #expect(value.sizeInBytes == MemoryLayout<RawPoint>.size)

        let decoded = try Data(encoding: value).unsafelyDecoding(as: RawPoint.self)
        #expect(decoded == value)
    }
}
