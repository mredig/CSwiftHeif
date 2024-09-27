public struct HEIFImageID: RawRepresentable {
	public let rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public init(_ rawValue: UInt32) {
		self.init(rawValue: rawValue)
	}
}
