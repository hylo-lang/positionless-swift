extension Swift.Slice: Collection {
  /// A slice has self as subsequence.
  typealias SubSeq = Self

  typealias Parts = SlicePartition<Base>

  func isEmpty() -> Bool {
    isEmpty
  }

  var first: Element {
    _read {
      yield self[self.startIndex]
    }
  }

  func withParts<R>(count partitionCount: Int, _ f: (inout Parts) -> R) -> R {
    var parts = SlicePartition(self, into: partitionCount)
    return f(&parts)
  }

  func withSlice<R>(_ f: (inout SubSeq) -> R) -> R {
    var projection = self
    return f(&projection)
  }
}

extension Swift.Slice: Slice {
  mutating func dropFirst() -> Bool {
    if isEmpty {
      return false
    }
    self.formIndex(after: &self._startIndex)
    return true
  }
}

extension Swift.Slice: BidirectionalCollection
where Base: Swift.BidirectionalCollection {
  var last: Element {
    _read {
      yield self[self.index(before: self.endIndex)]
    }
  }
}

extension Swift.Slice: BidirectionalSlice
where Base: Swift.BidirectionalCollection {
  mutating func dropLast() -> Bool {
    if isEmpty {
      return false
    }
    self.formIndex(before: &self._endIndex)
    return true
  }
}

extension Swift.Slice: RandomAccessCollection
where Base: Swift.RandomAccessCollection {}

extension Swift.Slice: RandomAccessSlice
where Base: Swift.RandomAccessCollection {}

extension Swift.Slice: MutableCollection
where Base: Swift.MutableCollection {
  var first: Element {
    _read {
      yield self[self.startIndex]
    }
    _modify {
      yield &self[self.startIndex]
    }
  }

  mutating func withMutableSlice<R>(_ f: (inout Swift.Slice<Base>) -> R) -> R {
    var projection = self
    let res = f(&projection)
    _writeBackElements(from: projection, to: &self[...])
    return res
  }

  mutating func withMutableParts<R>(
    count partitionCount: Int, _ f: (inout SlicePartition<Base>) -> R
  ) -> R {
    var parts = SlicePartition(self, into: partitionCount)
    let res = f(&parts)
    _writeBackElements(from: parts.storage, to: &self[...])
    return res
  }
}

extension Swift.Slice: MutableSlice
where Base: Swift.MutableCollection {
}

extension Swift.Slice: MutableBidirectionalCollection
where
  Base: Swift.MutableCollection,
  Base: Swift.BidirectionalCollection
{
  mutating func swapEnds() {
    swapAt(self.startIndex, self.index(before: self.endIndex))
  }

  var last: Element {
    _read {
      yield self[self.index(before: self.endIndex)]
    }
    _modify {
      yield &self[self.index(before: self.endIndex)]
    }
  }
}

extension Swift.Slice: MutableBidirectionalSlice
where
  Base: Swift.MutableCollection,
  Base: Swift.BidirectionalCollection
{}

extension Swift.Slice: MutableRandomAccessCollection
where
  Base: Swift.RandomAccessCollection,
  Base: Swift.MutableCollection
{}

extension Swift.Slice: MutableRandomAccessSlice
where
  Base: Swift.RandomAccessCollection,
  Base: Swift.MutableCollection
{}
