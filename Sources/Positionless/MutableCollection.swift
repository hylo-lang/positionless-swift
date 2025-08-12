/// A slice obtained from a `MutableCollection`.
protocol MutableSlice: Slice, MutableCollection {}

/// Partition obtained from a `MutableCollection`.
protocol MutablePartition: Partition
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

  /// Calls `f` with a partition that has parts same as self with `n` extra
  /// empty partitions at the end. Returns the result of computation of `f`.
  ///
  /// The shape of `self` becomes similar to shape of partition with which
  /// `f` was called, except the last part of `self` also contains elements
  /// of additional parts.
  ///
  /// - Precondition: `n >= 0`.
  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout Self) -> R) -> R

  /// Calls `f` with a partition that is projection of `self`.
  /// Returns the result of compuatation of `f`.
  ///
  /// - Postcondition: Changes in partition points of projection by `f` will
  /// not be visible in `self` after call to `f`.
  mutating func withProjection<R>(_ f: (inout Self) -> R) -> R

}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection
where
  SubSeq: MutableSlice,
  Parts: MutablePartition
{

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

  /// Calls `f` with a slice containing all elements of `self`.
  /// Returns the value returned by `f`.
  mutating func withMutableSlice<R>(_ f: (inout SubSeq) -> R) -> R

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  mutating func withMutableParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R
}
