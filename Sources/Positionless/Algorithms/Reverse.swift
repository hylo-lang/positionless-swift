extension MutableCollection where Self: BidirectionalCollection {
  /// Reverses the order of elements in `self`.
  ///
  /// - Complexity: O(n)
  mutating func reverse_() {  // FIXME: _ after reverse is to avoid ambiguity with stdlib reverse.
    // Start with [ _ | _ | a b c d e ]
    withMutablePartition(count: 3) { p in
      p.absorbAllFromNext(into: 1)  // --> [ _ | a b c d e | _ ]

      // Loop Invariant:
      // Every iteration of loop appends last element of `p[1]` to `p[0]` and
      // prepends first element of `p[1]` to `p[2]`.
      while p[part: 1].count > 1 {
        p.shrink(part: 1)  // --> [ _ | a b c d | e ]
        p.swapFirst(1, 2)  // --> [ _ | e b c d | a ]
        p.grow(part: 0)  // --> [ e | b c d | a ]
      }
    }
  }
}
