// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AVFoundation

extension AVAssetTrack {
    public struct SimpleMediaFormat {
        public var type: String
        public var subType: String
    }
    
    public var mediaFormats: [SimpleMediaFormat] {
        var formats = [SimpleMediaFormat]()
        
        guard let descriptions = formatDescriptions as? [CMFormatDescription] else { return [] }
        
        for (_, formatDesc) in descriptions.enumerated() {
            // Get String representation of media type (vide, soun, sbtl, etc.)
            guard let type = CMFormatDescriptionGetMediaType(formatDesc).fourCharCodeToString() else {
                continue
            }
            
            // Get String representation media subtype (avc1, aac, tx3g, etc.)
            guard let subType = CMFormatDescriptionGetMediaSubType(formatDesc).fourCharCodeToString() else {
                continue
            }
            // Format string as type/subType
            
            formats.append(SimpleMediaFormat(type: type, subType: subType))
        }
        return formats
    }
}
