import Foundation
import Algorithms
import HandyOperators

extension MoveTable {
	static func cached(create: @escaping () -> Self) -> CacheBuilder<Entry> {
		CacheBuilder(load: Self.init(entries:), create: { create().entries })
	}
	
	struct CacheBuilder<Value> {
		private var _name: String
		private var _forceComputation = false
		private var _load: ([Value]) -> MoveTable
		private var _create: () -> [Value]
		
		func name(_ name: String) -> Self {
			self <- { $0._name = name }
		}
		
		func forcingComputation() -> Self {
			self <- { $0._forceComputation = true }
		}
		
		func translate<NewValue>(
			to _: NewValue.Type = NewValue.self,
			load: @escaping ([NewValue]) -> [Value],
			create: @escaping ([Value]) -> [NewValue]
		) -> CacheBuilder<NewValue> {
			.init(
				_name: _name,
				_forceComputation: _forceComputation,
				_load: { _load(load($0)) },
				_create: { create(_create()) }
			)
		}
		
		// these are all fine
		func load() -> MoveTable where Value: Coordinate { unsafeLoad() }
		func load() -> MoveTable where Value: FixedWidthInteger { unsafeLoad() }
		func load<C>() -> MoveTable where Value == SolverMoveMap<C> { unsafeLoad() }
		
		func load<C>() -> MoveTable where Value == StandardSymmetryEntry<C> {
			translate(to: C.self) {
				$0
					.chunks(ofCount: StandardSymmetry.count)
					.lazy
					.map(Array.init)
					.map(Value.init)
			} create: {
				$0.flatMap(\.moves)
			}
			.load()
		}
		
		/// Only safe when `Value` is Plain Old Data
		private func unsafeLoad() -> MoveTable {
			_load(.loadOrCompute(
				name: _name,
				forceComputation: _forceComputation
			) { _create() })
		}
	}
}

extension MoveTable.CacheBuilder {
	init(
		load: @escaping ([Value]) -> MoveTable<Coord, Entry>,
		create: @escaping () -> [Value]
	) {
		self._name = "\(MoveTable.self)"
		self._load = load
		self._create = create
	}
}

extension Array {
	private typealias Size = UInt64
	
	static func loadOrCompute(
		name: String,
		forceComputation: Bool = false,
		compute: () -> Self
	) -> Self {
		let url = tablesFolder.appendingPathComponent("\(name).dat", isDirectory: false)
		try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
		
		let array: Self
		if !forceComputation, FileManager.default.fileExists(atPath: url.path) {
			array = load(from: url)
			print("loaded from \(url.path)")
		} else {
			array = compute()
			array.save(to: url)
			print("saved to \(url.path)")
		}
		return array
	}
	
	private static func load(from url: URL) -> Self {
		let file = try! FileHandle(forReadingFrom: url)
		defer { try! file.close() }
		let rawSize = try! file.read(upToCount: MemoryLayout<Size>.stride)!
		let compressed = try! file.readToEnd()!
		
		let size = Int(rawSize.unsafeAsArray(of: Size.self)[0])
		let data = compressed.decompress(size: size)
		
		return data.unsafeAsArray(of: Element.self)
	}
	
	private func save(to url: URL) {
		let data = Data(memoryOf: self)
		let rawSize = Data(memoryOf: [Size(data.count)])
		let compressed = data.compress()
		
		try? Data().write(to: url) // create file
		let file = try! FileHandle(forWritingTo: url)
		defer { try! file.close() }
		try! file.write(contentsOf: rawSize)
		try! file.write(contentsOf: compressed)
	}
}

private extension Data {
	func unsafeAsArray<Element>(of element: Element.Type = Element.self) -> [Element] {
		precondition(count % MemoryLayout<Element>.stride == 0)
		return withUnsafeBytes { buffer in
			Array(buffer.bindMemory(to: Element.self))
		}
	}
	
	init<Element>(memoryOf array: [Element]) {
		self = array.withUnsafeBufferPointer {
			.init(buffer: $0)
		}
	}
}

private let tablesFolder = try! FileManager.default.url(
	for: .applicationSupportDirectory,
	in: .userDomainMask,
	appropriateFor: nil,
	create: true
)
.appendingPathComponent("Tables", isDirectory: true)
