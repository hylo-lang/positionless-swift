/// A part of ArrayPartition.
struct ArrayPart<Element>: MutableCollection, RandomAccessCollection {

  /// Actual base storage of buffer.
  internal var storage: ArraySlice<Element>

  /// Creates instance of ArrayPart.
  public init(_ storage: ArraySlice<Element>) {
    self.storage = storage
  }

  /// The type of contained thing.
  typealias Element = Element

  /// A separation of `Self` into partitions.
  typealias Partition = ArrayPartition<Element>

  /// True iff `self` is empty.
  func isEmpty() -> Bool {
    storage.isEmpty
  }

  /// Number of elements.
  var count: Int { storage.count }

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element {
    _read {
      yield storage.first!
    }
    _modify {
      yield &storage[storage.startIndex]
    }
  }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  func withPartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R {
    var partition = ArrayPartition(storage, into: partitionCount)
    return f(&partition)
  }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  mutating func withMutablePartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R
  {
    var partition = ArrayPartition(storage, into: partitionCount)
    let res = f(&partition)
    _writeBackArraySlice(from: partition.storage, to: &storage)
    return res
  }

}
