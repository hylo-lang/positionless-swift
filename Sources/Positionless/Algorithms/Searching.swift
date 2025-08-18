extension Collection {
  /// Splits the collection at the first element that satisfies the given predicate.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  func splitFirst<R>(where predicate: (Element) -> Bool, _ f: (inout Parts) -> R) -> R {
    return withParts(count: 2) { p in
      while !p[part: 1].isEmpty() {
        if predicate(p[part: 1].first) {
          break
        }
        p.grow(part: 0)
      }
      return f(&p)
    }
  }
}

extension MutableCollection {
  /// Splits the collection at the first element that satisfies the given predicate.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  mutating func splitFirstMut<R>(where predicate: (Element) -> Bool, _ f: (inout Parts) -> R)
    -> R
  {
    return withMutableParts(count: 2) { p in
      while !p[part: 1].isEmpty() {
        if predicate(p[part: 1].first) {
          break
        }
        p.grow(part: 0)
      }
      return f(&p)
    }
  }
}
