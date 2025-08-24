/// A slice obtained from a `MutableBidirectionalCollection`.
protocol MutableBidirectionalSlice: MutableBidirectionalCollection, BidirectionalSlice, MutableSlice
{}

/// A partition obtained from `MutableBidirectionalCollection`.
protocol MutableBidirectionalPartitioning: BidirectionalPartitioning, MutablePartitioning
where MutableSubSeq: MutableBidirectionalSlice {}

/// A collection which supports mutating its element and backward traversal.
protocol MutableBidirectionalCollection: MutableCollection, BidirectionalCollection
where
  MutableSubSeq: MutableBidirectionalSlice,
  MutableParts: MutableBidirectionalPartitioning
{
  /// Swaps first and last element of collection.
  mutating func swapEnds()

  /// The last element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var last: Element { get set }
}
