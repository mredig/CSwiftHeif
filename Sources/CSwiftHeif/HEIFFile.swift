import Foundation
import Clibheif
import Clibde265

public class HEIFFile {
	private let context: OpaquePointer

	private var dataStore: UnsafeRawBufferPointer

	public var topImageCount: Int {
		Int(heif_context_get_number_of_top_level_images(context))
	}

	public var topLevelImageIDs: [HEIFImageID] {
		let count = topImageCount
		var holderArray: [HEIFImageID.RawValue] = .init(repeating: 0, count: count)

		let listCount = heif_context_get_list_of_top_level_image_IDs(context, &holderArray, Int32(count))
		if listCount != count {
			print("Warning: image id count mistmatch \(count) != \(listCount) - \(#file):\(#line)")
		}
		return holderArray.map(HEIFImageID.init(rawValue:))
	}

	public convenience init(file: URL) throws(HEIFError) {
		let data = try { () throws(HEIFError) -> Data in
			do {
				return try Data(contentsOf: file)
			} catch {
				throw HEIFError(other: error)
			}
		}()
		try self.init(data: data)
	}

	public init(data: Data) throws(HEIFError) {
		self.context = heif_context_alloc()
		self.dataStore = data.unsafeRawCopy
		try heif_context_read_from_memory_without_copy(context, dataStore.baseAddress, data.count, nil).check()
	}

	deinit {
		heif_context_free(context)
		dataStore.deallocate()
	}

	public func primaryImageID() throws(HEIFError) -> HEIFImageID {
		var id: UInt32 = 0
		try heif_context_get_primary_image_ID(context, &id).check()
		return .init(id)
	}

	public func image(for id: HEIFImageID) throws(HEIFError) -> HEIFImage {
		var handle: OpaquePointer!
		try heif_context_get_image_handle(context, id.rawValue, &handle).check()

		return HEIFImage(id: id, parent: self, handle: handle)
	}
}
