import Foundation
@preconcurrency import Clibheif

public enum HEIFColorspace: UInt32 {
	case undefined = 99
	case YCbCr = 0
	case RGB = 1
	case monochrome = 2
}

extension HEIFColorspace {
	var heif_colorspace: heif_colorspace { .init(rawValue: rawValue) }

	init(_ value: heif_colorspace) {
		self.init(rawValue: value.rawValue)!
	}
}
