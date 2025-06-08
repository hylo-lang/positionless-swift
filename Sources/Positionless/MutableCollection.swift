/// Mutable partitions of collection.
protocol MutableCollectionPartition: CollectionPartition
where Part: MutableCollection {

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int)

  /// The parts.
  ///
  /// Invariant: `parts.count == partitionCount`
  var parts: FixedArray<Part> { get set }

  /// `i`th part.
  subscript(_ i: Int) -> Part { get set }

  /// Calls `f` with a partition that has parts same as self with `n` extra
  /// empty partitions at the end. Returns the result of computation of `f`.
  ///
  /// The shape of `self` becomes similar to shape of partition with which
  /// `f` was called, except the last part of `self` also contains elements
  /// of additional parts.
  ///
  /// - Precondition: `n >= 0`.
  mutating func withAdditionalParts<R>(_ n: Int, _ f: (inout Self) -> R) -> R

  /// Calls `f` with a partition that is a copy of `self`.
  /// Returns the result of compuatation of `f`.
  mutating func withCopy<R>(_ f: (inout Self) -> R) -> R

}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection {

  /// A mutatble separation of `Self` into partitions.
  associatedtype MutablePartition: MutableCollectionPartition
  where MutablePartition.Part.Element == Element

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  func withMutablePartition<R>(
    into partitionCount: Int,
    _ f: (inout MutablePartition) -> R
  ) -> R

}
