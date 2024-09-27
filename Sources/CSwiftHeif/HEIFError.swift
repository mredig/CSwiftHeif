import Foundation
@preconcurrency import Clibheif

// sourcery: localizedError
public struct HEIFError: RawRepresentable, Error, LocalizedError, CustomStringConvertible {
	public let rawValue: heif_error

	public var code: Code { Code(rawValue: rawValue.code.rawValue) ?? .unknown }
	public var subcode: Subcode { Subcode(rawValue: rawValue.subcode.rawValue) ?? .unknown }
	public var message: String { other.map(\.localizedDescription) ?? String(cString: rawValue.message) }

	private var other: Error?

	public var description: String { message }
	public var errorDescription: String? { message }
	public var failureReason: String? { message }
	public var recoverySuggestion: String? { message }
	public var helpAnchor: String? { message }

	public init(rawValue: heif_error) {
		self.rawValue = rawValue
	}

	public init(other: Error){
		self.rawValue = .init(code: heif_error_code(4), subcode: heif_suberror_code(0), message: nil)
		self.other = other
	}

	func check() throws(Self) {
		guard code == .ok else {
			throw self
		}
	}

	public enum Code: UInt32 {
		// success
		case ok = 0

		// Input file does not exist.
		case inputDoesNotExist = 1

		// Error in input file. Corrupted or invalid content.
		case invalidInput = 2

		// Input file type is not supported.
		case unsupportedFiletype = 3

		// Image requires an unsupported decoder feature.
		case unsupportedFeature = 4

		// Library API has been used in an invalid way.
		case usageError = 5

		// Could not allocate enough memory.
		case memoryAllocationError = 6

		// The decoder plugin generated an error
		case decoderPluginError = 7

		// The encoder plugin generated an error
		case encoderPluginError = 8

		// Error during encoding or when writing to the output
		case encodingError = 9

		// Application has asked for a color profile type that does not exist
		case colorProfileDoesNotExist = 10

		// Error loading a dynamic plugin
		case pluginLoadingError = 11

		case unknown
	}

	public enum Subcode: UInt32 {
		// no further information available
		case unspecified = 0

		// --- Invalid_input ---

		// End of data reached unexpectedly.
		case endOfData = 100

		// Size of box (defined in header) is wrong
		case invalidBoxSize = 101

		// Mandatory 'ftyp' box is missing
		case noFtypBox = 102

		case noIdatBox = 103

		case noMetaBox = 104

		case noHdlrBox = 105

		case noHvcCBox = 106

		case noPitmBox = 107

		case noIpcoBox = 108

		case noIpmaBox = 109

		case noIlocBox = 110

		case noIinfBox = 111

		case noIprpBox = 112

		case noIrefBox = 113

		case noPictHandler = 114

		// An item property referenced in the 'ipma' box is not existing in the 'ipco' container.
		case ipmaBoxReferencesNonexistingProperty = 115

		// No properties have been assigned to an item.
		case noPropertiesAssignedToItem = 116

		// Image has no (compressed) data
		case noItemData = 117

		// Invalid specification of image grid (tiled image)
		case invalidGridData = 118

		// Tile-images in a grid image are missing
		case missingGridImages = 119

		case invalidCleanAperture = 120

		// Invalid specification of overlay image
		case invalidOverlayData = 121

		// Overlay image completely outside of visible canvas area
		case overlayImageOutsideOfCanvas = 122

		case auxiliaryImageTypeUnspecified = 123

		case noOrInvalidPrimaryItem = 124

		case noInfeBox = 125

		case unknownColorProfileType = 126

		case wrongTileImageChromaFormat = 127

		case invalidFractionalNumber = 128

		case invalidImageSize = 129

		case invalidPixiBox = 130

		case noAv1CBox = 131

		case wrongTileImagePixelDepth = 132

		case unknownNCLXColorPrimaries = 133

		case unknownNCLXTransferCharacteristics = 134

		case unknownNCLXMatrixCoefficients = 135

		// Invalid specification of region item
		case invalidRegionData = 136

		// Image has no ispe property
		case noIspeProperty = 137

		case cameraIntrinsicMatrixUndefined = 138

		case cameraExtrinsicMatrixUndefined = 139

		// Invalid JPEG 2000 codestream - usually a missing marker
		case invalidJ2KCodestream = 140

		case noVvcCBox = 141

		// icbr is only needed in some situations, this error is for those cases
		case noIcbrBox = 142

		// Decompressing generic compression or header compression data failed (e.g. bitstream corruption)
		case decompressionInvalidData = 150

		// --- Memory_allocation_error ---

		// A security limit preventing unreasonable memory allocations was exceeded by the input file.
		// Please check whether the file is valid. If it is, contact us so that we could increase the
		// security limits further.
		case securityLimitExceeded = 1000

		// There was an error from the underlying compression / decompression library.
		// One possibility is lack of resources (e.g. memory).
		case compressionInitialisationError = 1001

		// --- Usage_error ---

		// An item ID was used that is not present in the file.
		case nonexistingItemReferenced = 2000  // also used for Invalid_input

		// An API argument was given a NULL pointer, which is not allowed for that function.
		case nullPointerArgument = 2001

		// Image channel referenced that does not exist in the image
		case nonexistingImageChannelReferenced = 2002

		// The version of the passed plugin is not supported.
		case unsupportedPluginVersion = 2003

		// The version of the passed writer is not supported.
		case unsupportedWriterVersion = 2004

		// The given (encoder) parameter name does not exist.
		case unsupportedParameter = 2005

		// The value for the given parameter is not in the valid range.
		case invalidParameterValue = 2006

		// Error in property specification
		case invalidProperty = 2007

		// Image reference cycle found in iref
		case itemReferenceCycle = 2008


		// --- Unsupported_feature ---

		// Image was coded with an unsupported compression method.
		case unsupportedCodec = 3000

		// Image is specified in an unknown way, e.g. as tiled grid image (which is supported)
		case unsupportedImageType = 3001

		case unsupportedDataVersion = 3002

		// The conversion of the source image to the requested chroma / colorspace is not supported.
		case unsupportedColorConversion = 3003

		case unsupportedItemConstructionMethod = 3004

		case unsupportedHeaderCompressionMethod = 3005

		// Generically compressed data used an unsupported compression method
		case unsupportedGenericCompressionMethod = 3006

		// --- Encoder_plugin_error ---

		case unsupportedBitDepth = 4000


		// --- Encoding_error ---

		case cannotWriteOutputData = 5000

		case encoderInitialization = 5001
		case encoderEncoding = 5002
		case encoderCleanup = 5003

		case tooManyRegions = 5004


		// --- Plugin loading error ---

		case pluginLoadingError = 6000          // a specific plugin file cannot be loaded
		case pluginIsNotLoaded = 6001          // trying to remove a plugin that is not loaded
		case cannotReadPluginDirectory = 6002  // error while scanning the directory for plugins
		case noMatchingDecoderInstalled = 6003 // no decoder found for that compression format

		case unknown
	};
}

extension heif_error {
	var modern: HEIFError {
		HEIFError(rawValue: self)
	}

	func check() throws(HEIFError) {
		try modern.check()
	}
}

