//
//  RemoteTaskColor.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

struct RemoteTaskColor: RemoteObject {
    let id: String
    let name: String

    let backgroundRed: Double
    let backgroundGreen: Double
    let backgroundBlue: Double

    let borderRed: Double
    let borderGreen: Double
    let borderBlue: Double

    init(id: String, value: Any) throws {
        self.id = id

        let dict = try DictionaryDecoder(value)
        name = try dict.value(forKey: "name")

        func colors(from string: String) throws -> (red: Double, green: Double, blue: Double) {
            let scanner = Scanner(string: string)

            if string.hasPrefix("#") {
                // #4e342e
                var rgb: UInt32 = 0

                scanner.scanLocation = 1
                if !scanner.scanHexInt32(&rgb) { throw DecoderError.badType }

                return (
                    Double((rgb & 0xFF0000) >> 16) / 255.0,
                    Double((rgb & 0xFF00)   >> 8)  / 255.0,
                    Double((rgb & 0xFF))           / 255.0
                )
            }
            if string.hasPrefix("rgb") {
                // rgb(255, 172, 98)
                var red, green, blue: NSString?

                var result = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "("), into: nil)
                scanner.scanLocation += 1
                result = result && scanner.scanUpToCharacters(from: CharacterSet(charactersIn: ","), into: &red)
                scanner.scanLocation += 1
                result = result && scanner.scanUpToCharacters(from: CharacterSet(charactersIn: ","), into: &green)
                scanner.scanLocation += 1
                result = result && scanner.scanUpToCharacters(from: CharacterSet(charactersIn: ")"), into: &blue)

                if !result { throw DecoderError.badType }

                guard let r = Int(red! as String), let g = Int(green! as String), let b = Int(blue! as String) else {
                    throw DecoderError.badType
                }

                return (
                    Double(r) / 255.0,
                    Double(g) / 255.0,
                    Double(b) / 255.0
                )
            }

            throw DecoderError.badType
        }

        let background: String = try dict.value(forKey: "background")
        (backgroundRed, backgroundGreen, backgroundBlue) = try colors(from: background)

        let border: String = try dict.value(forKey: "border")
        (borderRed, borderGreen, borderBlue) = try colors(from: border)
    }
}
