import Testing
import CSwiftHeif
import Foundation
import SwiftPizzaSnips
import ResourceVendor

@Test func testHeif() async throws {
	// Write your test here and use APIs like `#expect(...)` to check expected conditions.

	let images = [
		"IMG_4812",
		"IMG_3456",
	]

	for imageName in images {
		let resource = try Bundle.resourceVendor.url(forResource: imageName, withExtension: "HEIC").unwrap()

		let file = try HEIFFile(file: resource)
		try test(heif: file)
	}
}

private func test(heif file: HEIFFile) throws {
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

	let jpgData = try image.jpegData()

	try jpgData
		.write(to: URL(filePath: "/Users/mredig/Swap/\(String.randomLoremIpsum(wordCount: 2)).jpg"))
	print()
}
