/// A separation of some collection into multiple contiguous partitions.
protocol CollectionPartition: ~Copyable {

  /// The type of each part.
  associatedtype Part: Collection

  /// Number of partitions.
  ///
  /// Invariant: `partitionCount >= 1`.
  var partitionCount: Int { get }

  /// The parts.
  ///
  /// Invariant: `parts.count == partitionCount`
  var parts: FixedArray<Part> { get }

  /// `i`th part.
  subscript(_ i: Int) -> Part { get }

  /// Increments the size of `i`th part by 1 and decrements the size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i + 1].isEmpty()`
  mutating func grow(part i: Int)

  /// Make the `i - 1`th part empty and takes all element into part `i`.
  ///
  /// - Precondition: `i > 0`.
  mutating func absorbAllFromPrev(into i: Int)

  /// Make the `i + 1`th part empty and takes all element into part `i`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func absorbAllFromNext(into i: Int)

  /// Make the `i`th part empty and takes all element into part `i - 1`.
  ///
  /// - Precondition: `i > 0`.
  mutating func transferAllToPrev(from i: Int)

  /// Make the `i`th part empty and takes all element into part `i + 1`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func transferAllToNext(from i: Int)

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
  func withCopy<R>(_ f: (inout Self) -> R) -> R

}

/// A multi-pass sequence of `Element`s.
protocol Collection<Element>: ~Copyable {

  /// The type of contained thing.
  associatedtype Element

  /// A separation of `Self` into prefix and suffix parts.
  associatedtype Partition: CollectionPartition where Partition.Part.Element == Element

  /// True iff `self` is empty.
  func isEmpty() -> Bool

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose last part contains all elements and other parts are empty.
  func partition<R>(into partitionCount: Int, _ f: (inout Partition) -> R) -> R

  /// Number of elements.
  var count: Int { get }

}
