import Testing
@testable import UnsafeCodable
import Foundation

// Custom struct with Int and Double
struct MyStructA: UnsafeCodable, Equatable {
    static let UNSAFE_CODABLE_VERSION: UInt8 = 1
    var x: Int
    var y: Double
    
    init(x: Int, y: Double) {
        self.x = x
        self.y = y
    }

    init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        x = try ptr.read(Int.self)
        y = try ptr.read(Double.self)
    }
    
    func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try ptr.write(value: x)
        try ptr.write(value: y)
    }
    
    var sizeInBytes: Int { MemoryLayout<UInt8>.size + MemoryLayout<Int>.size + MemoryLayout<Double>.size }
    var maximumSizeInBytes: Int { sizeInBytes }
}

// Custom struct with Bool and Int
struct MyStructB: UnsafeCodable, Equatable {
    static let UNSAFE_CODABLE_VERSION: UInt8 = 2
    var flag: Bool
    var val: Int
    
    init(flag: Bool, val: Int) {
        self.flag = flag
        self.val = val
    }
    
    init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        flag = try ptr.read(Bool.self)
        val = try ptr.read(Int.self)
    }
    
    func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try ptr.write(value: flag)
        try ptr.write(value: val)
    }
    
    var sizeInBytes: Int { MemoryLayout<UInt8>.size + MemoryLayout<Bool>.size + MemoryLayout<Int>.size }
    var maximumSizeInBytes: Int { sizeInBytes }
}

// Custom struct with String, Int (assume String is UnsafeCodable)
struct MyStructC: UnsafeCodable, Equatable {
    
    static let UNSAFE_CODABLE_VERSION: UInt8 = 3
    var name: String
    var count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
    
    init(from ptr: inout BoundedReadOnlyRawPointer) throws(UnsafeCodableError) {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        name = try String(from: &ptr)
        count = try ptr.read(Int.self)
    }
    
    func encode(to ptr: inout BoundedMutableRawPointer) throws(UnsafeCodableError) {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try name.encode(to: &ptr)
        try ptr.write(value: count)
    }
    
    var sizeInBytes: Int { MemoryLayout<UInt8>.size + name.sizeInBytes + MemoryLayout<Int>.size }
    var maximumSizeInBytes: Int { MemoryLayout<UInt8>.size + name.maximumSizeInBytes + MemoryLayout<Int>.size }
}

@Suite("Custom Struct UnsafeCodable Roundtrip")
struct CustomStructUnsafeCodableRoundtripTests {
    @Test("MyStructA encode and decode roundtrip")
    func myStructAEncodeDecode() async throws {
        let original = MyStructA(x: 42, y: 3.1415)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try MyStructA(from: &readPtr)
                #expect(decoded == original, "MyStructA decoded value should match original")
            }
        )
    }
    
    @Test("MyStructB encode and decode roundtrip")
    func myStructBEncodeDecode() async throws {
        let original = MyStructB(flag: true, val: -99)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try MyStructB(from: &readPtr)
                #expect(decoded == original, "MyStructB decoded value should match original")
            }
        )
    }
    
    @Test("MyStructC encode and decode roundtrip")
    func myStructCEncodeDecode() async throws {
        let original = MyStructC(name: "Hello UnsafeCodable", count: 7)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                let decoded = try MyStructC(from: &readPtr)
                #expect(decoded == original, "MyStructC decoded value should match original")
            }
        )
    }
    
    @Test("Decoding MyStructA as MyStructB should throw")
    func decodeMyStructAasMyStructBThrows() async throws {
        let original = MyStructA(x: 1, y: 2.0)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try MyStructB(from: &readPtr)
                }
            }
        )
    }

    @Test("Decoding MyStructB as MyStructA should throw")
    func decodeMyStructBasMyStructAThrows() async throws {
        let original = MyStructB(flag: false, val: 123)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try MyStructA(from: &readPtr)
                }
            }
        )
    }

    @Test("Decoding MyStructC as MyStructA should throw")
    func decodeMyStructCasMyStructAThrows() async throws {
        let original = MyStructC(name: "Bad", count: 77)
        try withBoundedBuffer(bufferSize: original.sizeInBytes,
            write: { mutablePtr in
                try original.encode(to: &mutablePtr)
            },
            read: { readPtr in
                #expect(throws: UnsafeCodableError.self) {
                    _ = try MyStructA(from: &readPtr)
                }
            }
        )
    }    
}

