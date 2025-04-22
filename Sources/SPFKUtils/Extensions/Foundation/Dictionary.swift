// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension Dictionary {
    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// - parameter dictionaries: A comma seperated list of dictionaries
    public mutating func merge<K, V>(dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }
}
