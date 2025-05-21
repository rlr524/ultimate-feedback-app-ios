//
//  Bundle-Decodable.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 7/13/24.
//

import Foundation

extension Bundle {
    // The method will return a T. So, we have T being used in four ways:
    // 1. We write the generic type parameter T in angle brackets after the method name, to tell
    // Swift there’s a placeholder called T and it must be Decodable.
    // 2. We specify T.Type as the second parameter, meaning that we can say exactly which type
    // we’re trying to decode using something like [String].self.
    // 3. Using T.self as the default value for the type means that if Swift can figure out we’re
    // decoding an array of strings from other context (like how the return value is being used),
    // then it will fill in the [String].self part for us.
    // 4. The return type is T.
    // So, giving decode a generic type, but not a free for all, it can be
    // anything, as long as it conforms to the Decodable protocol
    func decode<T: Decodable>(
        // Some file name that exists in whatever bundle is being used
        _ file: String,
        // Remeber T.self refers to the T type itself, not an object of T, so we're saying we're
        // using this method with the T type (generic) but whatever that is, use the type
        // itself, not an object of the type
        as type: T.Type = T.self,
        // Provide two params for a date decoding strategy and a key decoding strategy
        // but they will default to .deferredToDate and .useDefaultKeys, so they are optional params
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(_, context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
