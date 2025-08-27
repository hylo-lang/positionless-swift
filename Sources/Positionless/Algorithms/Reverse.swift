extension MutableBidirectionalCollection {
  /// Reverses the order of elements in `self`.
  ///
  /// - Complexity: Exactly `count`/2 swaps.
  mutating func reverse_() {  // FIXME: _ after reverse is to avoid ambiguity with stdlib reverse.
    withMutableSlice { rest in
      while !rest.isEmpty() {
        rest.swapEnds()
        _ = rest.dropFirst()
        _ = rest.dropLast()
      }
    }
  }
}
