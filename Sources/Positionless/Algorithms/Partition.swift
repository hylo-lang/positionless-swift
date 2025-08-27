extension MutableCollection {

  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into the suffix, preserving the relative order of only non-matching
  /// elements. The resulting partition is then projected and passed to `f` with
  /// returning its result.
  ///
  /// - Postcondition: For resulting partition `p`, `p.partitionCount == 2`.
  ///
  /// - Complexity: Exactly `count` predicate application. No more than `count` swaps.
  mutating func halfStablePartition<R>(by predicate: (Element) -> Bool, _ f: (MutableParts) -> R)
    -> R
  {
    return withMutableParts(count: 2) { p in
      p.halfStablePartition(by: predicate)
      return f(p)
    }
  }

  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into the suffix, preserving the relative order of each part.
  /// The resulting partition is then projected and passed to `f` with returning its result.
  ///
  /// - Postcondition: For resulting partition `p`, `p.partitionCount == 2`.
  ///
  /// - Complexity: Exactly `count` `predicate` application. At most `count.log2(count)` swaps.
  mutating func stablePartition<R>(by predicate: (Element) -> Bool, _ f: (MutableParts) -> R)
    -> R
  {
    return withMutableParts(count: 2) { p in
      p.stablePartition(by: predicate)
      return f(p)
    }
  }

}

extension MutablePartitioning {

  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into `parts[1]` and rest into `parts[0]`, preserving the
  /// relative ordering of `parts[0]` only.
  ///
  /// - Precondition:
  ///   - `partitionCount == 2`,
  ///   - `self[part: 0].isEmpty()`.
  ///
  /// - Complexity: Exactly `n` predicate application. No more than `n` swaps.
  ///   where `n == self[part: 1].count`.
  mutating func halfStablePartition(by predicate: (SubSeq.Element) -> Bool) {
    grow(part: 0, until: predicate)
    if self[part: 1].isEmpty() {
      return
    }

    withAdditionalMutableParts(1) { p in
      p.transferAllToNext(from: 1)
      /// Loop Invariant:
      /// - `p[part: 0]` contains elements that don't satisfy the predicate.
      /// - `p[part: 1]` contains elements that satisfy the predicate.
      /// - `p[part: 2]` contains the unexamined remainder of collection.
      while !p[part: 2].isEmpty() {
        if predicate(p[part: 2].first) {
          p.grow(part: 1)
        } else {
          p.swapFirst(1, 2)
          p.grow(part: 0)
          p.grow(part: 1)
        }
      }
    }

  }

  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into the `parts[1]` and rest into `parts[0]`, preserving the
  /// relative order of each part.
  ///
  /// - Precondition:
  ///   - `partitionCount == 2`,
  ///   - `self[part: 0].isEmpty()`.
  ///
  /// - Complexity: Exactly `n` `predicate` application. At most `n.log2(n)` swaps.
  ///   where `n == self[part: 1].count`.
  mutating func stablePartition(by predicate: (SubSeq.Element) -> Bool) {
    let n = self[part: 1].count
    stablePartition(by: predicate, count: n)
  }

  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into the `parts[1]` and rest into `parts[0]`, preserving the
  /// relative order of each part.
  ///
  /// - Precondition:
  ///   - `partitionCount == 2`,
  ///   - `self[part: 0].isEmpty()`,
  ///   - `n == self[part: 1].count`.
  ///
  /// - Complexity: Exactly `n` `predicate` application. At most `n.log2(n)` swaps.
  private mutating func stablePartition(by predicate: (SubSeq.Element) -> Bool, count n: Int) {
    // _ | _
    if n == 0 {
      return
    }

    // _ | E
    if n == 1 {
      if !predicate(self[part: 1].first) {
        grow(part: 0)  // E | _
      }
      return
    }

    withAdditionalMutableParts(2) { p in
      // _ | E | _ | _
      p.transferAllToNext(from: 1)  // _ | _ | E | _
      let h = n / 2
      p.grow(part: 1, by: h)  // _ | h | n - h | _
      p.transferAllToNext(from: 2)  // _ | h | _ | n - h

      // Stable partition [_ | h] bisection
      p.withMutableParts(from: 0, to: 1) { $0.stablePartition(by: predicate, count: h) }
      // Stable partition [_ | n - h] bisection
      p.withMutableParts(from: 2, to: 3) { $0.stablePartition(by: predicate, count: n - h) }
      p.withMutableParts(from: 1, to: 2) { $0.rotate() }  // merge step

      p.transferAllToPrev(from: 1)
      p.shiftSections(from: 3, to: 1)  // prefix | suffix | _ | _
    }
  }

}
