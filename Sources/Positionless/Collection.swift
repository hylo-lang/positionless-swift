/// Models a subsequence of a collection.
protocol Slice: Collection {
  /// Drops the first element from slice and returns true. Returns false, if
  /// slice was empty.
  mutating func dropFirst() -> Bool
}

/// A separation of some collection into multiple contiguous slices.
protocol Partitioning: ~Copyable {

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

  /// Returns the result of passing to `f` the projection of self with
  /// `n` additional empty parts at end.
  ///
  /// - Precondition: `n >= 0`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitioning.
  /// The elements in additional parts of projection are appended to last part.
  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout SubSeq.Parts) -> R) -> R

  /// Returns the result of passing to `f` the projection of self containing
  /// parts in `[from, to]`.
  ///
  /// - Precondition:
  ///   - `from <= to`
  ///   - `from >= 0 && from < partitionCount`.
  ///   - `to >= 0 && to < partitionCount`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitioning.
  mutating func withParts<R>(from: Int, to: Int, _ f: (inout SubSeq.Parts) -> R) -> R

  /// Returns the result of passing to `f` the independent projection of `self`.
  mutating func withProjection<R>(_ f: (inout SubSeq.Parts) -> R) -> R

  /// Returns the result of passing to `f` an array of contiguous partitionings
  /// where each projected partitioning has `partitionCount` of `chunkSize`
  /// (except the last one, which may have less size in case `partitionCount % chunkSize != 0`).
  ///
  /// - Precondition: `chunkSize > 0`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitionings.
  mutating func withChunks<R>(of chunkSize: Int, _ f: (inout FixedArray<SubSeq.Parts>) -> R) -> R

}

extension Partitioning {

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

  /// A partitioning full `Self` into n disjoint contiguous SubSequences.
  associatedtype Parts: Partitioning
  where
    Parts.SubSeq == SubSeq

  /// True iff `self` is empty.
  func isEmpty() -> Bool

  /// The first element of the collection.
  ///
  /// - Precondition: `!isEmpty()`
  var first: Element { get }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose all parts except last part is empty.
  func withParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R

  /// Returns the result of passing to `f` the slice of `self` which contains
  /// all elements of `self`.
  func withSlice<R>(_ f: (inout SubSeq) -> R) -> R

  /// Number of elements.
  ///
  /// Complexity: O(1) for RandomAccessCollection; otherwise O(n) where n is
  /// number of elements in collection.
  var count: Int { get }

}
