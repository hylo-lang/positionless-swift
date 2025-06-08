/// Partitioning of an array.
struct ArrayPartition<Element>: CollectionPartition {

  /// Actual array storage
  private let storage: UnsafeBufferPointer<Element>

  /// Start index of every partition and last index.
  private var partitionStartIndexes: [Int]

  /// Creates instance of ArrayPartition.
  public init(of storage: UnsafeBufferPointer<Element>, _ partitionStartIndexes: [Int]) {
    self.storage = storage
    self.partitionStartIndexes = partitionStartIndexes
  }

  typealias Part = ArrayPart<Element>

  var partitionCount: Int { partitionStartIndexes.count - 1 }

  var parts: FixedArray<ArrayPart<Element>> {
    _read {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in ArrayPart(storage, i, j) }
      yield FixedArray(partsArray)
    }
  }

  subscript(part i: Int) -> ArrayPart<Element> {
    ArrayPart(storage, partitionStartIndexes[i], partitionStartIndexes[i + 1])
  }

  mutating func grow(part i: Int) {
    partitionStartIndexes[i + 1] += 1
  }

  mutating func absorbAllFromPrev(into i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i - 1]
  }

  mutating func absorbAllFromNext(into i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i + 2]
  }

  mutating func transferAllToPrev(from i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i + 1]
  }

  mutating func transferAllToNext(from i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i]
  }

}

/// A part of ArrayPartition.
struct ArrayPart<Element>: Collection {

  /// Actual base storage of buffer.
  private let storage: UnsafeBufferPointer<Element>

  /// Start Index of part.
  private let startIndex: Int

  /// End Index of part.
  private let endIndex: Int

  /// Creates instance of ArrayPart.
  public init(_ storage: UnsafeBufferPointer<Element>, _ startIndex: Int, _ endIndex: Int) {
    self.storage = storage
    self.startIndex = startIndex
    self.endIndex = endIndex
  }

  typealias Element = Element

  typealias Partition = ArrayPartition<Element>

  func isEmpty() -> Bool {
    startIndex == endIndex
  }

  var first: Element {
    _read {
      yield storage[startIndex]
    }
  }

  func withPartition<R>(into partitionCount: Int, _ f: (inout Partition) -> R) -> R {
    var partition = ArrayPartition(
      of: storage, Array(repeating: startIndex, count: partitionCount) + [endIndex])
    return f(&partition)
  }

  var count: Int { endIndex - startIndex }

}

/// Mutable Partitioning of an array.
struct MutableArrayPartition<Element>: MutableCollectionPartition {

  /// Actual array storage
  private var storage: UnsafeMutableBufferPointer<Element>

  /// Start index of every partition and last index.
  private var partitionStartIndexes: [Int]

  /// Creates instance of ArrayPartition.
  public init(of storage: UnsafeMutableBufferPointer<Element>, _ partitionStartIndexes: [Int]) {
    self.storage = storage
    self.partitionStartIndexes = partitionStartIndexes
  }

  typealias Part = MutableArrayPart<Element>

  var partitionCount: Int { partitionStartIndexes.count - 1 }

  var parts: FixedArray<MutableArrayPart<Element>> {
    _read {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in MutableArrayPart(storage, i, j) }
      yield FixedArray(partsArray)
    }
    _modify {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in MutableArrayPart(storage, i, j) }
      var res = FixedArray(partsArray)
      yield &res
    }
  }

  subscript(part i: Int) -> MutableArrayPart<Element> {
    get {
      MutableArrayPart(storage, partitionStartIndexes[i], partitionStartIndexes[i + 1])
    }
    _modify {
      var part = MutableArrayPart(storage, partitionStartIndexes[i], partitionStartIndexes[i + 1])
      yield &part
    }
  }

  mutating func grow(part i: Int) {
    partitionStartIndexes[i + 1] += 1
  }

  mutating func absorbAllFromPrev(into i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i - 1]
  }

  mutating func absorbAllFromNext(into i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i + 2]
  }

  mutating func transferAllToPrev(from i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i + 1]
  }

  mutating func transferAllToNext(from i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i]
  }

  mutating func swapFirst(_ i: Int, _ j: Int) {
    storage.swapAt(partitionStartIndexes[i], partitionStartIndexes[j])
  }

  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout MutableArrayPartition) -> R) -> R {
    var partition = MutableArrayPartition(
      of: storage, partitionStartIndexes + Array(repeating: partitionStartIndexes.last!, count: n))
    let res = f(&partition)
    for i in 1..<partitionCount {
      partitionStartIndexes[i] = partition.partitionStartIndexes[i]
    }
    return res
  }

  mutating func withCopy<R>(_ f: (inout MutableArrayPartition) -> R) -> R {
    var copy = MutableArrayPartition(of: storage, partitionStartIndexes)
    return f(&copy)
  }

}

/// A part of ArrayPartition.
struct MutableArrayPart<Element>: MutableCollection {

  /// Actual base storage of buffer.
  private var storage: UnsafeMutableBufferPointer<Element>

  /// Start Index of part.
  private let startIndex: Int

  /// End Index of part.
  private let endIndex: Int

  /// Creates instance of ArrayPart.
  public init(_ storage: UnsafeMutableBufferPointer<Element>, _ startIndex: Int, _ endIndex: Int) {
    self.storage = storage
    self.startIndex = startIndex
    self.endIndex = endIndex
  }

  typealias Element = Element

  typealias Partition = ArrayPartition<Element>

  typealias MutablePartition = MutableArrayPartition<Element>

  func isEmpty() -> Bool {
    startIndex == endIndex
  }

  var count: Int { endIndex - startIndex }

  var first: Element {
    _read {
      yield storage[startIndex]
    }
    _modify {
      yield &storage[startIndex]
    }
  }

  func withPartition<R>(into partitionCount: Int, _ f: (inout Partition) -> R) -> R {
    var partition = ArrayPartition(
      of: UnsafeBufferPointer(storage),
      Array(repeating: startIndex, count: partitionCount) + [endIndex])
    return f(&partition)
  }

  mutating func withMutablePartition<R>(
    into partitionCount: Int, _ f: (inout MutableArrayPartition<Element>) -> R
  ) -> R {
    var partition = MutableArrayPartition(
      of: storage,
      Array(repeating: startIndex, count: partitionCount) + [endIndex])
    return f(&partition)
  }

}

extension Array: MutableCollection {

  typealias Partition = ArrayPartition<Element>

  typealias MutablePartition = MutableArrayPartition<Element>

  func isEmpty() -> Bool {
    isEmpty
  }

  var first: Element {
    _read {
      yield first!
    }
    _modify {
      var x = first!
      yield &x
    }
  }

  mutating func withMutablePartition<R>(
    into partitionCount: Int, _ f: (inout MutableArrayPartition<Element>) -> R
  ) -> R {
    let endIndex = endIndex
    return self.withUnsafeMutableBufferPointer { buffer in
      var partition = MutableArrayPartition(
        of: buffer, [Int](repeating: 0, count: partitionCount) + [endIndex])
      return f(&partition)
    }
  }

  func withPartition<R>(into partitionCount: Int, _ f: (inout ArrayPartition<Element>) -> R) -> R {
    self.withUnsafeBufferPointer { buffer in
      var partition = ArrayPartition(
        of: buffer, [Int](repeating: 0, count: partitionCount) + [endIndex])
      return f(&partition)
    }
  }

}
