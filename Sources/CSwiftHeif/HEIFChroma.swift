import Foundation
@preconcurrency import Clibheif

public enum HEIFChroma: UInt32 {
	case undefined = 99
	case monochrome = 0
	case c420 = 1
	case c422 = 2
	case c444 = 3
	case interleavedRGB = 10
	case interleavedRGBA = 11
	case interleavedRRGGBBBE = 12    // HDR, big endian.
	case interleavedRRGGBBAABE = 13  // HDR, big endian.
	case interleavedRRGGBBLE = 14    // HDR, little endian.
	case interleavedRRGGBBAALE = 15  // HDR, little endian.

	nonisolated(unsafe)
	public static let interleaved24Bit = Self.interleavedRGB
	nonisolated(unsafe)
	public static let interleaved32Bit = Self.interleavedRGBA
}

extension HEIFChroma {
	var heif_chroma: heif_chroma { .init(rawValue: rawValue) }

	init(_ value: heif_chroma) {
		self.init(rawValue: value.rawValue)!
	}
}
