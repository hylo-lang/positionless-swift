extension Collection {

  /// Splits the collection into partitioning of 2 so that the first element of the
  /// second part is the maximum element by given comparator, and then applies `f` to the partition.
  ///
  /// - Precondition:
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If the collection is empty, the second part is empty.
  ///   - If there are multiple maximum elements, the second part begins at
  ///     the last maximum element.
  ///
  /// - Complexity:
  ///   At most `max(count - 1, 0)` applications of `isLessThan`.
  func splitBeforeMaxElement<R>(
    by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool, _ f: (Parts) -> R
  ) -> R {
    return withParts(count: 2) { p in
      p.growUntilMaxElement(by: isLessThan)
      return f(p)
    }
  }

  /// Splits the collection into partitioning of 2 so that the first element of the
  /// second part is the minimum element by given comparator, and then applies `f` to the partition.
  ///
  /// - Precondition:
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If the collection is empty, the second part is empty.
  ///   - If there are multiple minimum elements, the second part begins at
  ///     the first minimum element.
  ///
  /// - Complexity:
  ///   At most `max(count - 1, 0)` applications of `isLessThan`.
  func splitBeforeMinElement<R>(
    by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool, _ f: (Parts) -> R
  ) -> R {
    return withParts(count: 2) { p in
      p.growUntilMinElement(by: isLessThan)
      return f(p)
    }
  }

}

extension MutableCollection {

  /// Splits the collection into mutable partitioning of 2 so that the first element of the
  /// second part is the maximum element by given comparator, and then applies `f` to the partitioning.
  ///
  /// - Precondition:
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If the collection is empty, the second part is empty.
  ///   - If there are multiple maximum elements, the second part begins at
  ///     the last maximum element.
  ///
  /// - Complexity:
  ///   At most `max(count - 1, 0)` applications of `isLessThan`.
  mutating func mutableSplitBeforeMaxElement<R>(
    by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool, _ f: (MutableParts) -> R
  ) -> R {
    return withMutableParts(count: 2) { p in
      p.growUntilMaxElement(by: isLessThan)
      return f(p)
    }
  }

  /// Splits the collection into mutable partitioning of 2 so that the first element of the
  /// second part is the minimum element by given comparator, and then applies `f` to the partition.
  ///
  /// - Precondition:
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If the collection is empty, the second part is empty.
  ///   - If there are multiple minimum elements, the second part begins at
  ///     the first minimum element.
  ///
  /// - Complexity:
  ///   At most `max(count - 1, 0)` applications of `isLessThan`.
  mutating func splitBeforeMinElement<R>(
    by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool, _ f: (MutableParts) -> R
  ) -> R {
    return withMutableParts(count: 2) { p in
      p.growUntilMinElement(by: isLessThan)
      return f(p)
    }
  }

}

extension Partitioning {

  /// Adjusts the boundary so that the second part begins at the last maximum element
  /// by given comparator.
  ///
  /// - Precondition:
  ///   - `partitionCount == 2`
  ///   - `self[part: 0].isEmpty()`,
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If `self[part: 1]` is empty, the partition is unchanged.
  ///   - If multiple elements are maximal, the boundary is placed
  ///     before the last such element.
  ///
  /// - Complexity:
  ///   At most `max(n - 1, 0)` applications of `isLessThan`, where
  ///   `n == self[part: 1].count`.
  mutating func growUntilMaxElement(by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool) {
    if self[part: 1].isEmpty() { return }

    withAdditionalParts(1) { p in
      p.transferAllToNext(from: 1)
      p.grow(part: 1)

      while !p[part: 2].isEmpty() {
        if !isLessThan(p[part: 2].first, p[part: 1].first) {
          p.transferAllToPrev(from: 1)
        }
        p.grow(part: 1)
      }
    }
  }

  /// Adjusts the boundary so that the second part begins at the first maximum element
  /// by given comparator.
  ///
  /// - Precondition:
  ///   - `partitionCount == 2`
  ///   - `self[part: 0].isEmpty()`,
  ///   - `isLessThan` follows strict-weak-ordering.
  ///
  /// - Postcondition:
  ///   - If `self[part: 1]` is empty, the partition is unchanged.
  ///   - If multiple elements are minimal, the boundary is placed
  ///     before the first such element.
  ///
  /// - Complexity:
  ///   At most `max(n - 1, 0)` applications of `isLessThan`, where
  ///   `n == self[part: 1].count`.
  mutating func growUntilMinElement(by isLessThan: (SubSeq.Element, SubSeq.Element) -> Bool) {
    if self[part: 1].isEmpty() { return }

    withAdditionalParts(1) { p in
      p.transferAllToNext(from: 1)
      p.grow(part: 1)

      while !p[part: 2].isEmpty() {
        if isLessThan(p[part: 2].first, p[part: 1].first) {
          p.transferAllToPrev(from: 1)
        }
        p.grow(part: 1)
      }
    }
  }

}
