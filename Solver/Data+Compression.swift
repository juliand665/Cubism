import Foundation
import Compression

private let algorithm = COMPRESSION_LZFSE

extension Data {
	func compress() -> Self {
		var destination = Data(count: count)
		let destinationCount = destination.count
		let compressedSize = self.withUnsafeBytes { sourceBuffer in
			destination.withUnsafeMutableBytes { destinationBuffer in
				compression_encode_buffer(
					destinationBuffer.bindMemory(to: UInt8.self).baseAddress!,
					destinationCount,
					sourceBuffer.bindMemory(to: UInt8.self).baseAddress!,
					count,
					nil, // manage your own scratch buffer lol
					algorithm
				)
			}
		}
		
		guard compressedSize > 0 else { fatalError("compression failed!") }
		return destination.prefix(compressedSize)
	}
	
	func decompress(size: Int) -> Self {
		var destination = Data(count: size)
		let decompressedSize = self.withUnsafeBytes { sourceBuffer in
			destination.withUnsafeMutableBytes { destinationBuffer in
				compression_decode_buffer(
					destinationBuffer.bindMemory(to: UInt8.self).baseAddress!,
					size,
					sourceBuffer.bindMemory(to: UInt8.self).baseAddress!,
					count,
					nil, // manage your own scratch buffer lol
					algorithm
				)
			}
		}
		precondition(decompressedSize == size)
		return destination
	}
}
