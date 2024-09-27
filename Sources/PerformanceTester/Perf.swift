import CSwiftHeif
import Foundation
import ResourceVendor

@main
struct Perf {
	static func main() async throws {
		let images = [
			"IMG_4812",
			"IMG_3456",
		]

		for imageName in images {
			let resource = try Bundle.resourceVendor.url(forResource: imageName, withExtension: "HEIC").unwrap()

			let file = try HEIFFile(file: resource)
			for _ in 0..<100 {
				try await test(heif: file)
			}
		}
	}

	private static func test(heif file: HEIFFile) async throws {
		print(file)
		print(file.topImageCount)
		print(file.topLevelImageIDs)

		let image = try file.image(for: file.primaryImageID())
	//	print(image)
	//	print(image.depthImageCount)
	//	print(image.hasAlpha)
	//	print(image.hasDepth)
	//	print(image.hasPremultipliedAlpha)
	//	try print(image.getChroma())
	//	try print(image.getColorspace())
	//	try print(image.getPixelAspectRatio())
	//	try print(image.getMetadata().map(\.description))
	//	try print(image.getChannels())
	//	try print(image.getBitsPerPixel())

		let start = Date()
		let jpgData = try await image.jpegData()
		let end = Date()

		print("Took \(end.timeIntervalSince(start)) seconds")

//		try jpgData
//			.write(to: URL(filePath: "/Users/mredig/Swap/\(String.randomLoremIpsum(wordCount: 2)).jpg"))
		print()
	}
}
