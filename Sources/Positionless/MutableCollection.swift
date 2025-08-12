/// A slice obtained from a `MutableCollection`.
protocol MutableSlice: Slice, MutableCollection {}

/// Partition obtained from a `MutableCollection`.
protocol MutablePartitioning: Partitioning
where SubSeq: MutableSlice {

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int)

  /// The parts.
  ///
  /// Invariant: `parts.count == partitionCount`
  var parts: FixedArray<SubSeq> { get set }

  /// `i`th part.
  subscript(part i: Int) -> SubSeq { get set }

  /// Returns the result of passing to `f` the mutable projection of self with
  /// `n` additional empty parts at end.
  ///
  /// - Precondition: `n >= 0`.
  ///
  /// - Postcondition: `self` adopts the boundaries of projected partitioning.
  /// The elements in additional parts of projection are appended to last part.
  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout Self) -> R) -> R

  /// Returns the result of passing to `f` the independent projection of `self`.
  mutating func withProjection<R>(_ f: (inout Self) -> R) -> R

}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection
where
  SubSeq: MutableSlice,
  Parts: MutablePartitioning
{

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

  /// Returns the result of passing to `f` the slice of `self` which contains
  /// all elements of `self`.
  mutating func withMutableSlice<R>(_ f: (inout SubSeq) -> R) -> R

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose all parts except last part is empty.
  mutating func withMutableParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R
}
