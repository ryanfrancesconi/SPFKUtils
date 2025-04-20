// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AVFoundation

extension AVURLAsset {
    public var audioFormat: AVAudioFormat? {
        // pull the input format out of the audio file...
        if let source = try? AVAudioFile(forReading: url) {
            return source.fileFormat

            // if that fails it might be a video, so check the tracks for audio
        } else {
            
            let audioTracks = tracks(withMediaType: .audio)

            guard !audioTracks.isEmpty else { return nil }

            let formatDescriptions = audioTracks.compactMap({
                $0.formatDescriptions as? [CMFormatDescription]
            }).reduce([], +)

            let audioFormats: [AVAudioFormat] = formatDescriptions.compactMap {
                AVAudioFormat(cmAudioFormatDescription: $0)
            }
            return audioFormats.first
        }
    }

    public var hasTimecode: Bool {
        !tracks(withMediaType: .timecode).isEmpty
    }

    public var hasAudio: Bool {
        !tracks(withMediaType: .audio).isEmpty
    }

    public var hasVideo: Bool {
        !tracks(withMediaType: .video).isEmpty
    }
}
