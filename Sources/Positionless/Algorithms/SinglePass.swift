/// Single Pass Algorithms
extension Collection {

  /// Applies `op` to each element in turn until it returns `true` or
  /// `self` is exhausted, returning `true` iff `op` ever returned
  /// `true`.
  @discardableResult
  func forEachUntil(_ op: (borrowing Element) -> Bool) -> Bool {
    withPartition(into: 2) { p in
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
