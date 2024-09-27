import Foundation
@preconcurrency import Clibheif

public enum HEIFChannel: UInt32, CaseIterable {
	case Y = 0
	case Cb = 1
	case Cr = 2
	case r = 3
	case g = 4
	case b = 5
	case alpha = 6
	case interleaved = 10
}

extension HEIFChannel {
	var heif_channel: heif_channel { .init(rawValue: rawValue) }

	init(_ value: heif_channel) {
		self.init(rawValue: value.rawValue)!
	}
}
