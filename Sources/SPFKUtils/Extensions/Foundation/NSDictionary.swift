// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension NSDictionary {
    public var keyValueDictionary: KeyValueDictionary? {
        guard let allKeys = allKeys as? [String] else {
            Log.error("Failed to convert keys to string")
            return nil
        }

        return dictionaryWithValues(forKeys: allKeys)
    }
}
