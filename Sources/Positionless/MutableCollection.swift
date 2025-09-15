/// A slice obtained from a `MutableCollection`.
protocol MutableSlice: Slice, MutableCollection {}

/// Partition obtained from a `MutableCollection`.
protocol MutablePartitioning: Partitioning {

  /// The type of each part subsequence.
  associatedtype MutableSubSeq: MutableSlice
  where
    MutableSubSeq.Element == SubSeq.Element,
    MutableSubSeq.SubSeq == SubSeq

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int)

  /// The parts.
  ///
  /// Invariant: `parts.count == partitionCount`
  var mutableParts: FixedArray<MutableSubSeq> { get set }

  /// `i`th part.
  subscript(mutablePart i: Int) -> MutableSubSeq { get set }

  /// Returns the result of passing to `f` the mutable projection of self with
  /// `n` additional empty parts at end.
  ///
  /// - Precondition: `n >= 0`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitioning.
  /// The elements in additional parts of projection are appended to last part.
  mutating func withAdditionalMutableParts<R>(
    _ n: Int, _ f: (inout MutableSubSeq.MutableParts) -> R
  ) -> R

  /// Returns the result of passing to `f` the mutable projection of self containing
  /// parts in `[from, to]`.
  ///
  /// - Precondition:
  ///   - `from <= to`
  ///   - `from >= 0 && from < partitionCount`.
  ///   - `to >= 0 && to < partitionCount`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitioning.
  mutating func withMutableParts<R>(
    from: Int, to: Int, _ f: (inout MutableSubSeq.MutableParts) -> R
  ) -> R

  /// Returns the result of passing to `f` the independent mutable projection of `self`.
  mutating func withMutableProjection<R>(
    _ f: (inout MutableSubSeq.MutableParts) -> R
  ) -> R

  /// Returns the result of passing to `f` an array of contiguous mutable partitionings
  /// where each projected partitioning has `partitionCount` of `chunkSize`
  /// (except the last one, which may have less size in case `partitionCount % chunkSize != 0`).
  ///
  /// - Precondition: `chunkSize > 0`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitionings.
  ///
  /// - Complexity: O(`chunkSize`).
  mutating func withMutableChunks<R>(
    of: Int, _ f: (inout FixedArray<MutableSubSeq.MutableParts>) -> R
  )
    -> R
}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection {

  /// Type of mutable subsequence of collection.
  associatedtype MutableSubSeq: MutableSlice
  where
    MutableSubSeq.Element == Element,
    MutableSubSeq.MutableSubSeq == MutableSubSeq,
    MutableSubSeq.SubSeq == SubSeq,
    MutableSubSeq.MutableParts == MutableParts,
    MutableSubSeq.Parts == Parts

  /// A mutable partitioning of `Self` into n disjoint contiguous SubSeq.
  associatedtype MutableParts: MutablePartitioning
  where
    MutableParts.MutableSubSeq == MutableSubSeq,
    MutableParts.SubSeq == SubSeq

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

  /// Returns the result of passing to `f` the slice of `self` which contains
  /// all elements of `self`.
  mutating func withMutableSlice<R>(_ f: (inout MutableSubSeq) -> R) -> R

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose all parts except last part is empty.
  mutating func withMutableParts<R>(
    count partitionCount: Int,
    _ f: (inout MutableParts) -> R
  ) -> R
}
