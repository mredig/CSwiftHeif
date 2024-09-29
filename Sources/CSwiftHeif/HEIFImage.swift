import Clibheif
import Foundation
import SwiftPizzaSnips
import TinySwiftJPEG

public class HEIFImage {
	var parent: HEIFFile

	private var handle: OpaquePointer
	private var _imagePointer: OpaquePointer?
	private var imagePointer: OpaquePointer {
		get throws(HEIFError) {
			lock.lock()
			defer { lock.unlock() }

			if let existing = _imagePointer {
				return existing
			} else {
				let newPointer = try getImagePointer()
				self._imagePointer = newPointer
				return newPointer
			}
		}
	}
	private let lock = NSLock()

	public let id: HEIFImageID

	public var width: Int {
		Int(heif_image_handle_get_width(handle))
	}

	public var height: Int {
		Int(heif_image_handle_get_height(handle))
	}

	public var size: CGSize {
		CGSize(width: Double(width), height: Double(height))
	}

	public var hasAlpha: Bool {
		heif_image_handle_has_alpha_channel(handle) == 1
	}

	public var hasPremultipliedAlpha: Bool {
		heif_image_handle_is_premultiplied_alpha(handle) == 1
	}

	/// No depth implemented beyond these two
	public var hasDepth: Bool {
		heif_image_handle_has_depth_image(handle) == 1
	}

	/// No depth implemented beyond these two
	public var depthImageCount: Int {
		Int(heif_image_handle_get_number_of_depth_images(handle))
	}

	init(id: HEIFImageID, parent: HEIFFile, handle: OpaquePointer) {
		self.id = id
		self.parent = parent
		self.handle = handle
	}

	deinit {
		heif_image_handle_release(handle)
		if let _imagePointer {
			heif_image_release(_imagePointer)
		}
	}

	private func getImagePointer(
		colorspace: HEIFColorspace = .undefined,
		chroma: HEIFChroma = .undefined
	) throws(HEIFError) -> OpaquePointer {
		var imagePointer: OpaquePointer!
		try heif_decode_image(
			handle,
			&imagePointer,
			colorspace.heif_colorspace,
			chroma.heif_chroma,
			nil).check()

		return imagePointer
	}

	public func getColorspace() throws(HEIFError) -> HEIFColorspace {
		try HEIFColorspace(heif_image_get_colorspace(imagePointer))
	}


	public func getChroma() throws(HEIFError) -> HEIFChroma {
		try HEIFChroma(heif_image_get_chroma_format(imagePointer))
	}

	#if !canImport(FoundationNetworking)
	public func getPixelAspectRatio() throws(HEIFError) -> (h: UInt32, v: UInt32) {
		var h: UInt32 = 0
		var v: UInt32 = 0
		try heif_image_get_pixel_aspect_ratio(imagePointer, &h, &v)
		return (h, v)
	}
	#endif

	public func getMetadata() throws(HEIFError) -> [HEIFMetadata] {
		let metadataCount = heif_image_handle_get_number_of_metadata_blocks(handle, nil)
		var metadataIDs: [HEIFImageID.RawValue] = .init(repeating: 0, count: Int(metadataCount))
		let gotCount = heif_image_handle_get_list_of_metadata_block_IDs(handle, nil, &metadataIDs, metadataCount)
		if gotCount != metadataCount {
			print("Warning: metadata id count mistmatch \(metadataCount) != \(gotCount) - \(#file):\(#line)")
		}

		let metadatas: [HEIFMetadata] = try { () throws(HEIFError) in
			var out: [HEIFMetadata] = []
			for id in metadataIDs {
				guard
					let cstrType = heif_image_handle_get_metadata_type(handle, id)
				else { continue }
				let cstrContent = heif_image_handle_get_metadata_content_type(handle, id)

				let size = heif_image_handle_get_metadata_size(handle, id)
				let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: size, alignment: 8)
				defer { buffer.deallocate() }

				try heif_image_handle_get_metadata(handle, id, buffer.baseAddress).check()

				let data = Data(buffer: buffer.bindMemory(to: UInt8.self)).with {
					let magic: [UInt8] = [0x45, 0x78, 0x69, 0x66]
					guard $0.starts(with: magic) == false else {
						return
					}
					guard $0[4...].starts(with: magic) else {
						return
					}
					$0.removeFirst(4)
				}

				out.append(
					HEIFMetadata(
						type: String(cString: cstrType),
						contentType: cstrContent.map { String(cString: $0) }?.emptyIsNil,
						metadata: data))
			}
			return out
		}()

		return metadatas
	}

	public func getChannels() throws(HEIFError) -> Set<HEIFChannel> {
		try _getChannels(imagePointer)
	}

	private func _getChannels(_ imagePointer: OpaquePointer) -> Set<HEIFChannel> {
		let channels = HEIFChannel.allCases.filter { channel in
			heif_image_has_channel(imagePointer, channel.heif_channel) == 1
		}

		return Set(channels)
	}

	public func getBitsPerPixel() throws(HEIFError) -> [HEIFChannel: (bitCount: Int, bitCountUsed: Int)] {
		let imagePointer = try imagePointer
		let channels = try getChannels()

		return channels.reduce(into: .init()) {
			let count = heif_image_get_bits_per_pixel(imagePointer, $1.heif_channel)
			let used = heif_image_get_bits_per_pixel_range(imagePointer, $1.heif_channel)
			$0[$1] = (Int(count), Int(used))
		}
	}

	public struct Plane: Sendable {
		public let data: Data
		public let rowStride: Int
		public let channel: HEIFChannel
	}

	public func getPlane(_ channel: HEIFChannel, copyData: Bool = true) throws(HEIFError) -> Plane {
		try _getPlane(channel, copyData: copyData, imagePointer: imagePointer)
	}
	public func _getPlane(_ channel: HEIFChannel, copyData: Bool = true, imagePointer: OpaquePointer) throws(HEIFError) -> Plane {
		var stride: Int32 = 0
		guard
			let planePointer = heif_image_get_plane_readonly(imagePointer, channel.heif_channel, &stride)
		else { throw HEIFError(other: SimpleError(message: "No image plane available for given channel")) }

		let size = Int(stride) * height
		let data = {
			if copyData {
				Data(bytes: planePointer, count: size)
			} else {
				Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: planePointer), count: size, deallocator: .none)
			}
		}()

		return Plane(data: data, rowStride: Int(stride), channel: channel)
	}

	private final class SendablePointer<Foo>: @unchecked Sendable {
		let pointer: UnsafeMutablePointer<Foo>

		init(pointer: UnsafeMutablePointer<Foo>) {
			self.pointer = pointer
		}
	}

	public func jpegData() async throws -> Data {
		let imagePointer = try getImagePointer(colorspace: .RGB, chroma: .interleaved24Bit)
		defer { heif_image_release(imagePointer) }

		let plane = try _getPlane(.interleaved, copyData: true, imagePointer: imagePointer)

		return try TinySwiftJPEG.encodeJPEG(
			from: plane.data,
			rowStride: plane.rowStride,
			width: width,
			height: height,
			channels: .rgb,
			quality: .good)
	}

	nonisolated
	private static func gdTrueColorAlpha(_ r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> Int32 {
		let a = UInt32(a) << 24
		let r = UInt32(r) << 16
		let g = UInt32(g) << 8
		let b = UInt32(b)
		return Int32(bitPattern: a | r | g | b)
	}
}
