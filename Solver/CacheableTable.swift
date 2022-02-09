import Foundation

protocol CacheableTable {
	associatedtype Value
	
	static var count: Int { get }
	var values: [Value] { get }
	
	init(values: [Value])
}

extension CacheableTable {
	static func loadOrCreate(forceComputation: Bool = false, compute: () -> Self) -> Self {
		let filename = "\(Self.self).dat"
		let url = tablesFolder.appendingPathComponent(filename)
		try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
		
		// TODO: gzip or some other form of compression? zip took it from 140 to 30 MB
		if !forceComputation, FileManager.default.fileExists(atPath: url.path) {
			let data = measureTime(as: "reading file") {
				try! Data(contentsOf: url)
			}
			let decompressed = measureTime(as: "decompressing") {
				data.decompress(size: rawSize)
			}
			let table = measureTime(as: "converting from data") {
				Self(data: decompressed)
			}
			print("loaded \(Self.self) from \(url.path)")
			return table
		} else {
			print("computing \(Self.self)")
			let table = compute()
			let data = measureTime(as: "converting to data") {
				table.data()
			}
			let compressed = measureTime(as: "compressing") {
				data.compress()
			}
			measureTime(as: "writing file") {
				try! compressed.write(to: url)
			}
			print("saved to \(url.path)")
			return table
		}
	}
	
	private static var rawSize: Int { MemoryLayout<Value>.stride * Self.count }
	
	private init(data: Data) {
		precondition(data.count == Self.rawSize)
		let values = data.withUnsafeBytes { buffer in
			Array(buffer.bindMemory(to: Value.self))
		}
		self.init(values: values)
	}
	
	private func data() -> Data {
		values.withUnsafeBufferPointer {
			Data(buffer: $0)
		}
	}
}

extension PruningTable: SimpleCacheableTable {
	typealias Value = UInt8
	
	static var count: Int { Coord.count }
	var values: [UInt8] { distances }
	
	init(values: [UInt8]) {
		self.distances = values
	}
}

protocol SimpleCacheableTable: CacheableTable {
	init()
}

extension SimpleCacheableTable {
	static func loadOrCreate(forceComputation: Bool = false) -> Self {
		loadOrCreate(forceComputation: forceComputation, compute: Self.init)
	}
}

extension MoveTable: CacheableTable {
	typealias Value = Entry
	
	static var count: Int { Coord.count }
	var values: [Entry] { entries }
	
	init(values: [Entry]) {
		self.entries = values
	}
}

private let tablesFolder = try! FileManager.default.url(
	for: .applicationSupportDirectory,
	   in: .userDomainMask,
	   appropriateFor: nil,
	   create: true
)
	.appendingPathComponent("Tables", isDirectory: true)
