/// A slice that allows manipulating elements from end.
protocol BidirectionalSlice: Slice, BidirectionalCollection {
  /// Drops last element from slice and returns true.
  /// If slice was empty, returns false.
  mutating func dropLast() -> Bool
}

/// Partitioning that supports backward traversal.
protocol BidirectionalPartition: Partition
where SubSeq: BidirectionalSlice {

  /// Decrements size of `i`th part by 1 and increments size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i].isEmpty()`
  mutating func shrink(part i: Int)

  /// Decrements size of `i`th partition by `n` and increments size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity:
  ///   - O(1) for RandomAccessCollection,
  ///   - O(n) otherwise.
  mutating func shrink(part i: Int, by n: Int)

}

extension BidirectionalPartition {

  /// Decrements size of `i`th partition by `n` and increments size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity:
  ///   - O(1) for RandomAccessCollection,
  ///   - O(n) otherwise.
  mutating func shrink(part i: Int, by n: Int) {
    for _ in 0..<n {
      shrink(part: i)
    }
  }

}

/// Collection that supports backward traversal.
protocol BidirectionalCollection: Collection
where
  SubSeq: BidirectionalSlice,
  Parts: BidirectionalPartition
{
  /// The last element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var last: Element { get }
}
