import Foundation

public extension Data {
	var unsafeRawCopy: UnsafeRawBufferPointer {
		let pointer = UnsafeMutableRawBufferPointer.allocate(byteCount: count, alignment: 4)
		pointer.copyBytes(from: self)
		return UnsafeRawBufferPointer(pointer)
	}
}
