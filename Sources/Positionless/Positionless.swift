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
  /// Invariant: `parts.count() == partitionCount`
  var parts: [Part] { get }

  /// Increments the size of `i`th part by 1 and decrements the size of `i + 1`th part by 1.
  ///
  /// - Precondition:
  ///   - `i < partitionCount - 1`
  ///   - `!parts[i + 1].isEmpty()`
  mutating func grow(part i: Int)

  /// Make the `i - 1`th part empty and takes all element into part `i`.
  ///
  /// - Precondition: `i > 0`.
  mutating func absorbAllFromLeft(into i: Int)

  /// Make the `i + 1`th part empty and takes all element into part `i`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func absorbAllFromRight(into i: Int)

  /// Make the `i`th part empty and takes all element into part `i - 1`.
  ///
  /// - Precondition: `i > 0`.
  mutating func transferAllToLeft(from i: Int)

  /// Make the `i`th part empty and takes all element into part `i + 1`.
  ///
  /// - Precondition: `i < partitionCount - 1`.
  mutating func transferAllToRight(from i: Int)

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

  /// Returns the number of elements.
  func count() -> Int

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned
  /// `true`.
  @discardableResult
  func forEachUntil(_ op: (borrowing Element) -> Bool) -> Bool

}

/// Algorithms
extension Collection {

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned
  /// `true`.
  @discardableResult
  func forEachUntil(_ op: (borrowing Element) -> Bool) -> Bool {
    partition(into: 2) { p in
      while !p.parts.last!.isEmpty() {
        if op(p.parts.last!.first) { return true }
        p.grow(part: 0)
      }
      return false
    }
  }

  /// Applies `op` to each element in turn.
  func forEach(_ op: (borrowing Element) -> Void) {
    forEachUntil {
      op($0)
      return false
    }
  }

  /// Returns the number of elements.
  func count() -> Int {
    var r = 0
    forEach { _ in r += 1 }
    return r
  }

  /// `combine`s each element in turn with `r`.
  func reduce<T: ~Copyable>(into r: inout T, combine: (inout T, borrowing Element) -> Void) {
    forEach {
      combine(&r, $0)
    }
  }

}

/// Mutable partitions of collection.
protocol MutableCollectionPartition: CollectionPartition
where Part: MutableCollection {

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int)

  /// The parts.
  ///
  /// Invariant: `parts.count() == partitionCount`
  var parts: [Part] { get set }

}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection
where Partition: MutableCollectionPartition {

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

}

/// A collection such as a deque, with an internally partitioned
/// structure.
///
/// It can be advantageous to operate on each partition of such a
/// collection independently.
protocol SegmentedCollection<Element>: Collection<Self.Element>, ~Copyable {

  /// A single partition.
  associatedtype Segment: Collection<Element>

  /// All the partitions.
  associatedtype Segments: Collection<Segment>

  /// The abutting partitions.
  var segments: Segments { get }

}

extension SegmentedCollection {

  /// Returns the number of elements.
  func count() -> Int {
    var r = 0
    segments.reduce(into: &r) { r, s in
      r += s.count()
    }
    return r
  }

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned `true`.
  @discardableResult
  func forEachUntil(_ op: (borrowing Element) -> Bool) -> Bool {
    segments.forEachUntil {
      $0.forEachUntil(op)
    }
  }

}
