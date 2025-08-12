/// Models a subsequence of a collection.
protocol Slice: Collection {
  /// Drops the first element from slice and returns true. Returns false, if
  /// slice was empty.
  mutating func dropFirst() -> Bool
}

/// A separation of some collection into multiple contiguous slices.
protocol Partition: ~Copyable {

  /// The type of each part subsequence.
  associatedtype SubSeq: Slice

  /// Number of partitions.
  ///
  /// Invariant: `partitionCount >= 1`.
  var partitionCount: Int { get }

  /// The parts.
  ///
  /// Invariant: `parts.count == partitionCount`
  var parts: FixedArray<SubSeq> { get }

  /// `i`th part.
  subscript(part i: Int) -> SubSeq { get }

  /// Increments the size of `i`th part by 1 and decrements the size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i + 1].isEmpty()`
  mutating func grow(part i: Int)

  /// Increments the size of `i`th part by `n` and decrements the size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i + 1].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity:
  ///   - O(1) for RandomAccessCollection,
  ///   - O(n) otherwise.
  mutating func grow(part i: Int, by n: Int)

  /// Make the `i`th part empty and takes all element into part `i - 1`.
  ///
  /// - Precondition: `i > 0`.
  mutating func transferAllToPrev(from i: Int)

  /// Make the `i`th part empty and takes all element into part `i + 1`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func transferAllToNext(from i: Int)

}

extension Partition {

  /// Increments the size of `i`th part by `n` and decrements the size of
  /// `i + 1`th part by `n`.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `parts[i + 1].count >= n`
  ///   - `n >= 0`
  ///
  /// - Complexity:
  ///   - O(1) for RandomAccessCollection,
  ///   - O(n) otherwise.
  mutating func grow(part i: Int, by n: Int) {
    for _ in 0..<n {
      grow(part: i)
    }
  }

  /// Shifts all elements of `[from, to)` parts to `to` part.
  ///
  /// - Postcondition:
  ///   - If `from < to`, `from`, `from + 1`, ... `to - 1` elements would be
  ///     shifted to `to`.
  ///   - If `from > to`, `from`, `from - 1`, ... `to + 1` elements would be
  ///     shifted to `to`.
  mutating func shiftSections(from: Int, to: Int) {
    if from < to {
      for i in from..<to {
        transferAllToNext(from: i)
      }
    } else if to < from {
      for i in stride(from: from, to: to, by: -1) {
        transferAllToPrev(from: i)
      }
    }
  }

}

/// A multi-pass sequence of `Element`s.
protocol Collection<Element>: ~Copyable {

  /// The type of contained thing.
  associatedtype Element

  /// Type of subsequence of collection.
  associatedtype SubSeq: Slice
  where
    SubSeq.Element == Element,
    SubSeq.SubSeq == SubSeq,
    SubSeq.Parts == Parts

  /// A partition full `Self` into n disjoint contiguous SubSequences.
  associatedtype Parts: Partition
  where
    Parts.SubSeq == SubSeq

  /// True iff `self` is empty.
  ///
  /// Complexity: O(1).
  func isEmpty() -> Bool

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  func withParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R

  /// Calls `f` with a slice containing all elements of `self`.
  /// Returns the value returned by `f`.
  func withSlice<R>(_ f: (inout SubSeq) -> R) -> R

  /// Number of elements.
  var count: Int { get }

}
