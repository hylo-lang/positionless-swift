/// Partitioning of an array.
struct ArrayPartition<Element>: MutableCollectionPartition {

  /// Actual array storage
  var storage: ArraySlice<Element>

  /// Start index of every partition and last index.
  var partitionStartIndexes: [Int]

  /// Creates instance of ArrayPartition.
  public init(_ storage: ArraySlice<Element>, _ partitionStartIndexes: [Int]) {
    self.storage = storage
    self.partitionStartIndexes = partitionStartIndexes
  }

  /// Creates instance of ArrayPartition, with all `partitionCount - 1` parts
  /// empty and last part covering full `storage`.
  public init(_ storage: ArraySlice<Element>, into partitionCount: Int) {
    self.init(
      storage,
      Array(repeating: storage.startIndex, count: partitionCount)
        + [storage.endIndex])
  }

  typealias Part = ArrayPart<Element>

  var partitionCount: Int { partitionStartIndexes.count - 1 }

  var parts: FixedArray<ArrayPart<Element>> {
    _read {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in ArrayPart(storage[i..<j]) }
      yield FixedArray(partsArray)
    }
    _modify {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in ArrayPart(storage[i..<j]) }

      var res = FixedArray(partsArray)
      yield &res

      // Write back updated content of every part to storage.
      for i in 0..<res.count {
        _writeBackArraySlice(from: res[i].storage, to: &storage)
      }
    }
  }

  subscript(part i: Int) -> ArrayPart<Element> {
    get {
      ArrayPart(storage[partitionStartIndexes[i]..<partitionStartIndexes[i + 1]])
    }
    _modify {
      var part =
        ArrayPart(storage[partitionStartIndexes[i]..<partitionStartIndexes[i + 1]])
      yield &part
      _writeBackArraySlice(from: part.storage, to: &storage)
    }
  }

  mutating func grow(part i: Int) {
    partitionStartIndexes[i + 1] += 1
  }

  mutating func grow(part i: Int, by n: Int) {
    partitionStartIndexes[i + 1] += n
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

  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout ArrayPartition) -> R) -> R {
    var partition = ArrayPartition(
      storage, partitionStartIndexes + Array(repeating: partitionStartIndexes.last!, count: n))
    let res = f(&partition)
    for i in 1..<partitionCount {
      partitionStartIndexes[i] = partition.partitionStartIndexes[i]
    }
    _writeBackArraySlice(from: partition.storage, to: &storage)
    return res
  }

  mutating func withCopy<R>(_ f: (inout ArrayPartition) -> R) -> R {
    var copy = ArrayPartition(storage, partitionStartIndexes)
    let res = f(&copy)
    _writeBackArraySlice(from: copy.storage, to: &storage)
    return res
  }

}
