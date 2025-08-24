extension MutableCollection {
  /// Reorders the collection in place so that all elements matching the predicate
  /// are moved into the suffix, preserving the relative order of the non-matching
  /// elements. The resulting partition is then projected and passed to `f`.
  ///
  /// - Postcondition: For resulting partition `p`, `p.partitionCount == 2`.
  ///
  /// - Complexity: Exactly `count` predicate application. No more than `count` swaps.
  mutating func halfStablePartition<R>(by predicate: (Element) -> Bool, _ f: (MutableParts) -> R)
    -> R
  {
    return mutableSplitFirst(where: predicate) { bisection in
      if bisection[part: 1].isEmpty() {
        return f(bisection)
      }

      bisection.withAdditionalMutableParts(1) { trisection in
        trisection.transferAllToNext(from: 1)
        /// Loop Invariant:
        /// - `trisection[part: 0]` contains elements that don't satisfy the predicate.
        /// - `trisection[part: 1]` contains elements that satisfy the predicate.
        /// - `trisection[part: 2]` contain remaining elements to be processed.
        while !trisection[part: 2].isEmpty() {
          if predicate(trisection[part: 2].first) {
            trisection.grow(part: 1)
          } else {
            trisection.swapFirst(1, 2)
            trisection.grow(part: 0)
            trisection.grow(part: 1)
          }
        }
      }

      return f(bisection)
    }
  }
}
