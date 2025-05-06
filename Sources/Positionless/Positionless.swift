/// A separation of some collection into two parts: a prefix and a suffix.
protocol CollectionBisection: ~Copyable {

  /// The type of each part.
  associatedtype Part: Collection

  /// The parts.
  var parts: (prefix: Part, suffix: Part) { get }

  /// Increments the size of `prefix` and decrements the size of `suffix`.
  ///
  /// - Precondition: `!parts.suffix.isEmpty()`
  mutating func growPrefixBy1()

}

extension CollectionBisection {

  /// The first part.
  var prefix: Part {
    _read {
      yield parts.prefix
    }
  }

  /// The second (last) part.
  var suffix: Part {
    _read {
      yield parts.suffix
    }
  }

}

/// A multi-pass sequence of `Element`s.
protocol Collection<Element>: ~Copyable {

  /// The type of contained thing.
  associatedtype Element

  /// A separation of `Self` into prefix and suffix parts.
  associatedtype Bisection: CollectionBisection where Bisection.Part.Element == Element

  /// True iff `self` is empty.
  func isEmpty() -> Bool

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get }

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose first part is empty.
  func withBisection<R>(_ f: (inout Bisection) -> R) -> R

  // The above could almost be modeled as:
  //   var bisection { get nonmutating set }
  //
  // What we'd like is to project a mutable instance of Bisection
  // (which doesn't allow element mutation) from an immutable collection.

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
    withBisection { p in
      while !p.suffix.isEmpty() {
        if op(p.prefix.first) { return true }
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

/// A collection bisection that can be mutated.
protocol MutableCollectionBisection: CollectionBisection where Part: MutableCollection {

  /// Swaps first element of `prefix` and `suffix`.
  ///
  /// - Precondition: `!parts.prefix.isEmpty() && !parts.suffix.isEmpty()`
  mutating func swapFirstElements()

  /// The parts.
  var parts: (prefix: Part, suffix: Part) { get set }

}

extension MutableCollectionBisection {

  /// The first part.
  var prefix: Part {
    _read {
      yield parts.prefix
    }
    _modify {
      yield &parts.prefix
    }
  }

  /// The second (last) part.
  var suffix: Part {
    _read {
      yield parts.suffix
    }
    _modify {
      yield &parts.suffix
    }
  }

}

protocol MutableCollection<Element>: Collection {
  /// A mutable separation of `Self` into prefix and suffix.
  associatedtype MutableBisection: MutableCollectionBisection
  where
    Bisection.Part.Element == Element,
    MutableBisection.Part.Element == Element

  /// Returns the result of passing to `f` the partitioning of `self`
  /// whose first part is empty.
  func withMutableBisection<R>(_ f: (inout MutableBisection) -> R) -> R

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

func myFunc<C: MutableCollection<Int>>(_ col: inout C) {
  col.withMutableBisection { (b: inout C.MutableBisection) in
    b.prefix.first = 4
  }
}
