/// Single Pass Algorithms
extension Collection {

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned
  /// `true`.
  @discardableResult
  func forEachUntil(_ op: (borrowing Element) -> Bool) -> Bool {
    withPartition(into: 2) { p in
      while !p[part: 1].isEmpty() {
        if op(p[part: 1].first) { return true }
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

  /// Returns true if `count == other.count` and all elements in `self` is
  /// equal to all elements in `other` in order.
  func equals<C: Collection>(_ other: C) -> Bool
  where
    Element == C.Element,
    Element: Equatable
  {
    withPartition(into: 2) { p1 in
      other.withPartition(into: 2) { p2 in
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
