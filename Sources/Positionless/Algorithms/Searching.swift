extension Partitioning {

  /// Grows given part until first element next part satisfies given predicate or becomes empty.
  ///
  /// - Precondition: `i < partitionCount - 1`
  ///
  /// - Complexity: No more than `self[part: i + 1].count` to `grow`.
  mutating func grow(part i: Int, until predicate: (SubSeq.Element) -> Bool) {
    while !self[part: i + 1].isEmpty() {
      if predicate(self[part: i + 1].first) {
        break
      }
      grow(part: i)
    }
  }

}

extension Collection {

  /// Splits the collection at the first element that satisfies the given predicate.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  func splitFirst<R>(
    where predicate: (Element) -> Bool,
    _ f: (inout Parts) -> R
  ) -> R {
    return withParts(count: 2) { p in
      p.grow(part: 0, until: predicate)
      return f(&p)
    }
  }

  /// Splits the collection at the first element that is equal to given element.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  func splitFirst<R>(
    on e: Element,
    _ f: (inout Parts) -> R
  ) -> R
  where Element: Equatable {
    splitFirst(where: { $0 == e }, f)
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
  mutating func mutableSplitFirst<R>(
    where predicate: (Element) -> Bool,
    _ f: (inout Parts) -> R
  )
    -> R
  {
    return withMutableParts(count: 2) { p in
      p.grow(part: 0, until: predicate)
      return f(&p)
    }
  }

  /// Splits the collection at the first element that is equal to given element.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  mutating func mutableSplitFirst<R>(
    on e: Element,
    _ f: (inout Parts) -> R
  ) -> R
  where Element: Equatable {
    mutableSplitFirst(where: { $0 == e }, f)
  }

}
