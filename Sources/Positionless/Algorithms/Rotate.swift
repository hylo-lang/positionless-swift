extension MutablePartitioning {

  /// Exchanges the elements of `parts[0]` with those of `parts[1]` without
  /// reordering elements within each part.
  ///
  /// - Precondition: `partitionCount == 2`.
  ///
  /// - Complexity: no more than `count` swaps.
  mutating func rotate() {
    withAdditionalParts(2) { p in
      p.shiftSections(from: 1, to: 3)
      p.transferAllToNext(from: 0)
      p.rotateQuadrisection(partitionPointMatters: true)
    }
  }

  /// Moves elements of `part[3]` to `part[0]` without disturbing relative
  /// ordering of rest of elements.
  ///
  /// - Precondition:
  ///   - `part[3]` contains elements that should be followed by elements in
  ///     `part[1]` after rotation.
  ///   - `part[0].isEmpty() && part[2].isEmpty()`.
  ///
  /// - Postcondition:
  ///   - `part[0]` **only** contains all elements of given `part[3]` with
  ///     maintaining relative ordering.
  ///
  /// - Complexity: no more than `count` swaps.
  private mutating func rotateQuadrisection(partitionPointMatters: Bool) {
    // Loop Invariant:
    // - After every iteration, `part[0]` would contain elements moved from
    //   `part[3]` with same relative ordering.
    // - `part[1]` and `part[3]` contains rest of elements for rotation such that
    //   `part[3]` elements should be followed by elements in `part[1]` after rotation.
    // - `part[2]` is empty.
    while true {
      // Handle base cases.
      if self[part: 3].isEmpty() {
        shiftSections(from: 0, to: 3)
        return
      }
      if self[part: 1].isEmpty() {
        shiftSections(from: 3, to: 0)
        return
      }

      // We have 2 regions of possibly-unequal lengths parts[1] and parts[3].
      //
      // [_ | a b c d e f g | _ | h i j]   or   [_ | a b c | _ | d e f g h i j]
      while !self[part: 3].isEmpty() {
        // Exchange the leading elements parts[1] and part[3] by
        //  - putting exchanged part[3] elements in part[0]
        //  - putting exchanged part[1] elements in part[2]
        //
        // [h i j | d e f g | a b c | _ ]   or   [d e f | _ | a b c | g h i j]
        swapFirst(1, 3)
        grow(part: 0)
        grow(part: 2)

        if self[part: 1].isEmpty() {
          // Second case:
          // More elements from parts[3] needs to be in parts[0].
          //
          // [d e f | a b c | _ | g h i j]
          transferAllToPrev(from: 2)
        }
      }

      // When parts[3] is empty, parts[0] contain the final elements after rotation.
      // But parts[1] and parts[2] might not be in right order. So reorder them
      // to maintain loop invariant.
      //
      // First case:
      // [h i j | d e f g | _ | a b c]
      transferAllToNext(from: 2)  // This results a subproblem for rotate.

      if partitionPointMatters {
        // parts[0] boundary should not be touched, so recurse on self projection to
        // preserve boundaries and break as rotation should be done.
        //
        // First case:
        // [h i j | a b c d | _ | e f g]
        withProjection { $0.rotateQuadrisection(partitionPointMatters: false) }
        break
      }
      // else solve the subproblem in while loop.
    }
  }

}
