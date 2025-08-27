struct SlicePartitioning<Base>
where Base: Swift.Collection {

  /// Full collection slice.
  var storage: Swift.Slice<Base>

  /// Start index of every partition and end index.
  var partitionStartIndexes: [Base.Index]

  /// Creates instance of SlicePartitioning.
  public init(_ storage: Swift.Slice<Base>, _ partitionStartIndexes: [Base.Index]) {
    self.storage = storage
    self.partitionStartIndexes = partitionStartIndexes
  }

  /// Creates an instance of partition such that all the parts except last part
  /// is empty and last part contains all the elements in partition.
  public init(_ storage: Swift.Slice<Base>, into partitionCount: Int) {
    self.init(
      storage,
      Array(repeating: storage.startIndex, count: partitionCount)
        + [storage.endIndex])
  }
}

extension SlicePartitioning: Partitioning {

  typealias SubSeq = Swift.Slice<Base>

  var partitionCount: Int {
    partitionStartIndexes.count - 1
  }

  mutating func grow(part i: Int) {
    storage.formIndex(after: &partitionStartIndexes[i + 1])
  }

  mutating func grow(part i: Int, by n: Int) {
    storage.formIndex(&partitionStartIndexes[i + 1], offsetBy: n)
  }

  mutating func transferAllToPrev(from i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i + 1]
  }

  mutating func transferAllToNext(from i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i]
  }

  var parts: FixedArray<Swift.Slice<Base>> {
    _read {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in self.storage[i..<j] }
      yield FixedArray(partsArray)
    }
  }

  subscript(part i: Int) -> Swift.Slice<Base> {
    storage[partitionStartIndexes[i]..<partitionStartIndexes[i + 1]]
  }

  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout SlicePartitioning<Base>) -> R) -> R {
    var partition = SlicePartitioning(
      storage, partitionStartIndexes + Array(repeating: partitionStartIndexes.last!, count: n))
    let res = f(&partition)
    for i in 1..<partitionCount {
      partitionStartIndexes[i] = partition.partitionStartIndexes[i]
    }
    return res
  }

  mutating func withParts<R>(from: Int, to: Int, _ f: (inout SubSeq.Parts) -> R) -> R {
    var partition = SlicePartitioning(storage, Array(partitionStartIndexes[from...to + 1]))
    let res = f(&partition)
    for (i, j) in zip(from + 1...to, 1...) {
      partitionStartIndexes[i] = partition.partitionStartIndexes[j]
    }
    return res
  }

  mutating func withProjection<R>(_ f: (inout SlicePartitioning<Base>) -> R) -> R {
    var projection = SlicePartitioning(storage, partitionStartIndexes)
    return f(&projection)
  }

}

extension SlicePartitioning: BidirectionalPartitioning
where Base: Swift.BidirectionalCollection {
  mutating func shrink(part i: Int) {
    storage.formIndex(before: &partitionStartIndexes[i + 1])
  }

  mutating func shrink(part i: Int, by n: Int) {
    storage.formIndex(&partitionStartIndexes[i + 1], offsetBy: -n)
  }
}

extension SlicePartitioning: RandomAccessPartitioning
where Base: Swift.RandomAccessCollection {
}

extension SlicePartitioning: MutablePartitioning
where Base: Swift.MutableCollection {

  typealias MutableSubSeq = Swift.Slice<Base>

  mutating func swapFirst(_ i: Int, _ j: Int) {
    storage.swapAt(partitionStartIndexes[i], partitionStartIndexes[j])
  }

  var mutableParts: FixedArray<Swift.Slice<Base>> {
    _read {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in self.storage[i..<j] }
      yield FixedArray(partsArray)
    }
    _modify {
      let partsArray =
        zip(partitionStartIndexes, partitionStartIndexes.dropFirst())
        .map { (i, j) in self.storage[i..<j] }
      var res = FixedArray(partsArray)
      yield &res
      _writeBackElements(from: res[0], to: &storage)
    }
  }

  subscript(mutablePart i: Int) -> Swift.Slice<Base> {
    _read {
      yield storage[partitionStartIndexes[i]..<partitionStartIndexes[i + 1]]
    }
    _modify {
      var part = storage[partitionStartIndexes[i]..<partitionStartIndexes[i + 1]]
      yield &part
      _writeBackElements(from: part, to: &storage)
    }
  }

  mutating func withAdditionalMutableParts<R>(
    _ n: Int,
    _ f: (inout MutableSubSeq.MutableParts) -> R
  )
    -> R
  {
    var partition = SlicePartitioning(
      storage, partitionStartIndexes + Array(repeating: partitionStartIndexes.last!, count: n))
    let res = f(&partition)
    for i in 1..<partitionCount {
      partitionStartIndexes[i] = partition.partitionStartIndexes[i]
    }
    _writeBackElements(from: partition.storage, to: &storage)
    return res
  }

  mutating func withMutableParts<R>(
    from: Int, to: Int, _ f: (inout MutableSubSeq.MutableParts) -> R
  ) -> R {
    var partition = SlicePartitioning(storage, Array(partitionStartIndexes[from...to + 1]))
    let res = f(&partition)
    for (i, j) in zip(from + 1...to, 1...) {
      partitionStartIndexes[i] = partition.partitionStartIndexes[j]
    }
    _writeBackElements(from: partition.storage, to: &storage)
    return res
  }

  mutating func withMutableProjection<R>(_ f: (inout MutableSubSeq.MutableParts) -> R) -> R {
    var projection = SlicePartitioning(storage, partitionStartIndexes)
    let res = f(&projection)
    _writeBackElements(from: projection.storage, to: &storage)
    return res
  }

}

extension SlicePartitioning: MutableBidirectionalPartitioning
where
  Base: Swift.MutableCollection,
  Base: Swift.BidirectionalCollection
{}

extension SlicePartitioning: MutableRandomAccessPartitioning
where
  Base: Swift.MutableCollection,
  Base: Swift.RandomAccessCollection
{}
