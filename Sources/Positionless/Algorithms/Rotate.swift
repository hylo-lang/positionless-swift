extension MutableCollectionPartition {

  /// Mutates the bisection so that after operation `parts[0]` contains elements
  /// of `parts[1]` currently and `parts[1]` after operation contains elements of
  /// `parts[0]` currently. Relative ordering of individual part is preserved.
  ///
  /// - Precondition: `partitionCount == 2`.
  /// - Postcondition: `partitionCount == 2`
  /// - Complexity: O(n) where `n == parts[0].count + parts[1].count`.
  mutating func rotate() {
    withAdditionalParts(2) { p in
      p.shiftSections(from: 1, to: 3)
      p.transferAllToNext(from: 0)
      p.rotateQuadrisection(partitionPointMatters: true)
    }
  }

  /// Assumes quadrisection of following form:
  /// D | F | T | S
  ///
  /// D -> Done elements. Elements which are in their proper place.
  /// F -> Elements for rotation in first half.
  /// E -> Empty buffer for temporary use purposes.
  /// S -> Elements for rotation in second half.
  ///
  /// After rotation, D contains the final first half and F, E, S contains
  /// elements of second half in order.
  private mutating func rotateQuadrisection(partitionPointMatters: Bool) {
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
          //
          // More elements from parts[3] needs to be in parts[0]. Thus make the
          // quadrisection again in D | F | E | S form to again perform exchange
          // loop.
          //
          // [d e f | a b c | _ | g h i j]
          transferAllToPrev(from: 2)
        }
      }

      // When parts[3] is empty, parts[0] contain the final elements after rotation.
      // But parts[1] and parts[2] might not be in right order. So, make them
      // in D | F | E | S form.
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
