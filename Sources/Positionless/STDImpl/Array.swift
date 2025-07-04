extension Array: MutableCollection, RandomAccessCollection {

  /// Separation of array into contiguous partitions.
  typealias Partition = ArrayPartition<Element>

  /// Returns true iff array doesn't contain any element.
  func isEmpty() -> Bool {
    isEmpty
  }

  /// First element of array.
  ///
  /// - Precondition: `!isEmpty()`.
  var first: Element {
    _read {
      yield first!
    }
    _modify {
      var x = first!
      yield &x
    }
  }

  /// Returns the result of passing to `f` the partitioning of `self` whose
  /// whose last part contains all elements and other parts are empty.
  func withPartition<R>(
    count partitionCount: Int, _ f: (inout ArrayPartition<Element>) -> R
  ) -> R {
    var partition = ArrayPartition(self[...], into: partitionCount)
    return f(&partition)
  }

  /// Returns the result of passing to `f` the partitioning of `self` whose
  /// whose last part contains all elements and other parts are empty.
  mutating func withMutablePartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R
  {
    var partition = ArrayPartition(self[...], into: partitionCount)
    let res = f(&partition)
    _writeBackArraySlice(from: partition.storage, to: &self[...])
    return res
  }

}
