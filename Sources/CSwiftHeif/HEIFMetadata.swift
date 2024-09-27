import Foundation

public struct HEIFMetadata: Sendable {
	let type: String
	let contentType: String?
	let metadata: Data
}

extension HEIFMetadata: CustomStringConvertible, CustomDebugStringConvertible {
	private var commonDescription: String {
		[
			"HEIFMetadata (\(type)): ",
			contentType.map { "\t\($0)" },
		]
			.compactMap { $0 }
			.joined(separator: "\n")
	}
	public var description: String {
		let common = commonDescription

		let mdString = {
			guard
				let str = String(data: metadata, encoding: .utf8)
			else { return metadata.description }
			return str
		}().prefixingLines(with: "\t")

		return "\(common)\n\(mdString)"
	}

	public var debugDescription: String {
		let common = commonDescription

		let mdString = {
			guard
				let str = String(data: metadata, encoding: .utf8)
			else {
				return metadata
					.map({
						let hex = String($0, radix: 16)
						guard hex.count == 2 else {
							return "0\(hex)"
						}
						return hex
					})
					.joined(separator: " ")
			}
			return str
		}().prefixingLines(with: "\t")

		return "\(common)\n\(mdString)"
	}
}
