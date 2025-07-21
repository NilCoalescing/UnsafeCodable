# UnsafeCodable

A Swift package for memory-safe (ish), high-performance serialization and deserialization directly. Provides protocols and utilities for encoding and decoding Swift types with explicit bounds checking and versioning support.


## Example: Conforming a Custom Struct to UnsafeCodable

Here's how you can make your own struct conform to `UnsafeCodable`:

```swift
struct Point: UnsafeCodable {
    static let UNSAFE_CODABLE_VERSION: UInt8 = 1
    var x: Int32
    var y: Int32

    init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
    }

    init(from ptr: inout BoundedReadOnlyRawPointer) throws {
        try ptr.assertVersion(Self.UNSAFE_CODABLE_VERSION)
        x = try ptr.read(Int32.self)
        y = try ptr.read(Int32.self)
    }

    func encode(to ptr: inout BoundedMutableRawPointer) throws {
        try ptr.write(value: Self.UNSAFE_CODABLE_VERSION)
        try ptr.write(value: x)
        try ptr.write(value: y)
    }

    var sizeInBytes: Int {
        MemoryLayout<UInt8>.size + 2 * MemoryLayout<Int32>.size
    }

    var maximumSizeInBytes: Int {
        sizeInBytes
    }
}
```



## Decoding & Encoding

To decode your types from some data use `data.unsafelyDecoding(as: Point.self)` and `Data(encoding: Point())`.

