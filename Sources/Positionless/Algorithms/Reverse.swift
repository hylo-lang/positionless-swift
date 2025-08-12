extension MutableBidirectionalCollection {
  /// Reverses the order of elements in `self`.
  ///
  /// - Complexity: O(n)
  mutating func reverse_() {  // FIXME: _ after reverse is to avoid ambiguity with stdlib reverse.
    withMutableSlice { rest in
      while rest.count > 1 {
        rest.swapEnds()
        _ = rest.dropFirst()
        _ = rest.dropLast()
      }
    }
  }
}
