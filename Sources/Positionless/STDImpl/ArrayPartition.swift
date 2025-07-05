/// Partitioning of an array.
struct ArrayPartition<Element>: MutableCollectionPartition, RandomAccessCollectionPartition {

  /// Actual array storage
  var storage: ArraySlice<Element>

  /// Start index of every partition and last index.
  var partitionStartIndexes: [Int]

  /// Creates instance of ArrayPartition.
  public init(_ storage: ArraySlice<Element>, _ partitionStartIndexes: [Int]) {
    self.storage = storage
    self.partitionStartIndexes = partitionStartIndexes
  }

  /// Creates instance of ArrayPartition, whose last part contains all elements
  /// and other parts are empty.
  public init(_ storage: ArraySlice<Element>, into partitionCount: Int) {
    self.init(
      storage,
      Array(repeating: storage.startIndex, count: partitionCount)
        + [storage.endIndex])
  }

  /// Type of a part of partitioning.
  typealias Part = ArrayPart<Element>

  /// Number of parts in partitioning.
  var partitionCount: Int { partitionStartIndexes.count - 1 }

  /// All parts.
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

  /// ith part of partitioning.
  ///
  /// - Precondition: `i >= 0 && i < partitionCount`
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

  /// Increments the size of `i`th part by 1 and decrements the size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i + 1].isEmpty()`
  mutating func grow(part i: Int) {
    partitionStartIndexes[i + 1] += 1
  }

  /// Increments the size of `i`th part by `n` and decrements the size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i + 1].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity: O(1)
  mutating func grow(part i: Int, by n: Int) {
    partitionStartIndexes[i + 1] += n
  }

  /// Make the `i`th part empty and takes all element into part `i - 1`.
  ///
  /// - Precondition: `i > 0`.
  mutating func transferAllToPrev(from i: Int) {
    partitionStartIndexes[i] = partitionStartIndexes[i + 1]
  }

  /// Make the `i`th part empty and takes all element into part `i + 1`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func transferAllToNext(from i: Int) {
    partitionStartIndexes[i + 1] = partitionStartIndexes[i]
  }

  /// Decrements size of `i`th part by 1 and increments size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i].isEmpty()`
  mutating func shrink(part i: Int) {
    partitionStartIndexes[i + 1] -= 1
  }

  /// Decrements size of `i`th partition by `n` and increments size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity: O(n).
  mutating func shrink(part i: Int, by n: Int) {
    partitionStartIndexes[i + 1] -= n
  }

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int) {
    storage.swapAt(partitionStartIndexes[i], partitionStartIndexes[j])
  }

  /// Calls `f` with a partition that has parts same as self with `n` extra
  /// empty partitions at the end. Returns the result of computation of `f`.
  ///
  /// The shape of `self` becomes similar to shape of partition with which
  /// `f` was called, except the last part of `self` also contains elements
  /// of additional parts.
  ///
  /// - Precondition: `n >= 0`.
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

  /// Calls `f` with a partition that is a copy of `self`.
  /// Returns the result of compuatation of `f`.
  mutating func withCopy<R>(_ f: (inout ArrayPartition) -> R) -> R {
    var copy = ArrayPartition(storage, partitionStartIndexes)
    let res = f(&copy)
    _writeBackArraySlice(from: copy.storage, to: &storage)
    return res
  }

}
