/// Single Pass Algorithms
extension Collection {

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned
  /// `true`.
  @discardableResult
  func forEach(until op: (borrowing Element) -> Bool) -> Bool {
    withParts(count: 2) { p in
      while !p[part: 1].isEmpty() {
        if op(p[part: 1].first) { return true }
        p.grow(part: 0)
      }
      return false
    }
  }

  /// Applies `op` to each element in turn.
  func forEach(_ op: (borrowing Element) -> Void) {
    forEach {
      op($0)
      return false
    }
  }

  /// Returns true iff all elements satisfy the given predicate.
  ///
  /// - Complexity: No more than `count` application of `predicate`.
  func all(satisfy predicate: (Element) -> Bool) -> Bool {
    return !forEach(until: { !predicate($0) })
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

  /// Returns true if `count == other.count` and all elements in `self` is
  /// equal to all elements in `other` in order.
  static func == <C: Collection>(lhs: Self, rhs: C) -> Bool
  where
    Self.Element == C.Element,
    Element: Equatable
  {
    lhs.withParts(count: 2) { p1 in
      rhs.withParts(count: 2) { p2 in
        while !p1[part: 1].isEmpty() && !p2[part: 1].isEmpty() {
          if p1[part: 1].first != p2[part: 1].first {
            return false
          }
          p1.grow(part: 0)
          p2.grow(part: 0)
        }
        return p1[part: 1].isEmpty() && p2[part: 1].isEmpty()
      }
    }
  }

}
