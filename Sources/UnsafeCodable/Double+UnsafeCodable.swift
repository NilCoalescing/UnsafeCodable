//
//  Double+UnsafeCodable.swift
//  strolly
//
//  Created by Matthaus Woolard on 04/04/2024.
//

import Foundation

extension Double: UnsafeCodable {}


extension Int: UnsafeCodable {}

extension Int8: UnsafeCodable {}

extension Int16: UnsafeCodable {}

extension Int32: UnsafeCodable {}

extension Int64: UnsafeCodable {}

extension UInt: UnsafeCodable {}

extension UInt8: UnsafeCodable {}

extension UInt16: UnsafeCodable {}

extension UInt32: UnsafeCodable {}

extension UInt64: UnsafeCodable {}

extension Float: UnsafeCodable {}

extension Bool: UnsafeCodable {}


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Duration: UnsafeCodable {}


@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: UnsafeCodable {}


#if arch(x86_64)
extension Float80: UnsafeCodable {}
#endif


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension Int128: UnsafeCodable {}


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
extension UInt128: UnsafeCodable {}


extension StaticString: UnsafeCodable {}
