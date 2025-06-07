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
