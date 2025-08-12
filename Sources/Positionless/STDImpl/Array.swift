extension Array: MutableRandomAccessCollection {

  /// Subsequence of array.
  typealias SubSeq = Swift.Slice<Self>

  /// Separation of array into contiguous partitions.
  typealias Parts = SlicePartitioning<Self>

  /// Returns true iff array doesn't contain any element.
  func isEmpty() -> Bool {
    isEmpty
  }

  /// First element of array.
  ///
  /// - Precondition: `!isEmpty()`.
  var first: Element {
    _read {
      yield self[self.startIndex]
    }
    _modify {
      yield &self[self.startIndex]
    }
  }

  /// Last element of array.
  ///
  /// - Precondition: `isEmpty()`.
  var last: Element {
    _read {
      yield self[self.endIndex - 1]
    }
    _modify {
      yield &self[self.endIndex - 1]
    }
  }

  /// Swap first and last element of array.
  mutating func swapEnds() {
    swapAt(self.startIndex, self.endIndex - 1)
  }

  /// Calls `f` with a slice containing all elements of `self`.
  /// Returns the value returned by `f`.
  func withSlice<R>(_ f: (inout SubSeq) -> R) -> R {
    var s = makeSlice()
    return f(&s)
  }

  /// Calls `f` with a slice containing all elements of `self`.
  /// Returns the value returned by `f`.
  mutating func withMutableSlice<R>(_ f: (inout SubSeq) -> R) -> R {
    var s = makeSlice()
    let res = f(&s)
    _writeBackElements(from: s, to: &self)
    return res
  }

  /// Returns the result of passing to `f` the partitioning of `self` whose
  /// whose last part contains all elements and other parts are empty.
  func withParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R {
    var partition = SlicePartitioning(makeSlice(), into: partitionCount)
    return f(&partition)
  }

  /// Returns the result of passing to `f` the partitioning of `self` whose
  /// whose last part contains all elements and other parts are empty.
  mutating func withMutableParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R {
    var partition = SlicePartitioning(makeSlice(), into: partitionCount)
    let res = f(&partition)
    _writeBackElements(from: partition.storage, to: &self)
    return res
  }

  private func makeSlice() -> Swift.Slice<Self> {
    return Swift.Slice(base: self, bounds: startIndex..<endIndex)
  }

}
