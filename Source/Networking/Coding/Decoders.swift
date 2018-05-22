//
//  Decoders.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

enum DecoderError: Error {
    case badType
}

class ValueDecoder<T> {
    let value: T

    init(_ object: Any) throws {
        guard let value = object as? T else {
            log.warnMessage("Object \(object) doesn't match \(T.self) type")
            throw DecoderError.badType
        }
        self.value = value
    }
}

class ArrayDecoder<Element>: Sequence {
    private let array: [Element]

    init(_ object: Any) throws {
        guard let array = object as? [Element] else {
            log.warnMessage("Object is not an array: \(object)")
            throw DecoderError.badType
        }
        self.array = array
    }

    func makeIterator() -> Array<Element>.Iterator {
        return array.makeIterator()
    }

    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try array.map(transform)
    }
}

class DictionaryDecoder: Sequence {
    private let dict: [String:Any]

    init(_ object: Any) throws {
        guard let dict = object as? [String:Any] else {
            log.warnMessage("Object is not a dictionary: \(object)")
            throw DecoderError.badType
        }
        self.dict = dict
    }

    func value<T>(forKey key: String) throws -> T {
        if T.self is ExpressibleByNilLiteral.Type {
            fatalError("This method cannot be used with optionals. Please use optionalValue:forKey:")
        }

        guard let value = dict[key] as? T else {
            let object = String(describing: dict[key])
            log.warnMessage("Object \(object) for key \(key) not matching type \(T.self)")
            throw DecoderError.badType
        }
        return value
    }

    func optionalValue<T>(forKey key: String) throws -> T? {
        let unknown = dict[key]

        if unknown is NSNull {
            return nil
        }

        guard let value = unknown as? T? else {
            let object = String(describing: dict[key])
            log.warnMessage("Object \(object) for key \(key) not matching type \(T.self)")
            throw DecoderError.badType
        }
        return value
    }

    func nestedDict(forKey key: String) throws -> DictionaryDecoder {
        let object: Any = try value(forKey: key)
        return try DictionaryDecoder(object)
    }

    /// Returns true for "1", else for "0".
    func boolFromString(forKey key: String) throws -> Bool {
        let string: String = try value(forKey: key)

        switch string {
        case "0":
            return false
        case "1":
            return true
        default:
            log.warnMessage("String \(string) for key \(key) cannot be converted to bool")
            throw DecoderError.badType
        }
    }

    /// Returns integer value stored in string
    func intFromString(forKey key: String) throws -> Int {
        let string: String = try value(forKey: key)
        guard let value = Int(string) else {
            throw DecoderError.badType
        }

        return value
    }

    func date(forKey key: String) throws -> Date {
        let string: String = try value(forKey: key)

        guard let interval = TimeInterval(string) else {
            log.warnMessage("String \(string) for key \(key) cannot be converted to TimeInterval")
            throw DecoderError.badType
        }

        return Date(timeIntervalSince1970: interval)
    }

    func optionalDate(forKey key: String) throws -> Date? {
        let theString: String? = try optionalValue(forKey: key)
        guard let string = theString else {
            return nil
        }

        guard let interval = TimeInterval(string) else {
            log.warnMessage("String \(string) for key \(key) cannot be converted to TimeInterval")
            throw DecoderError.badType
        }

        if interval == 0 {
            return nil
        }

        return Date(timeIntervalSince1970: interval)
    }

    func makeIterator() -> Dictionary<String,Any>.Iterator {
        return dict.makeIterator()
    }
}
