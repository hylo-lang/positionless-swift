/// A slice obtained from `MutableRandomAccessCollection`.
protocol MutableRandomAccessSlice: MutableBidirectionalSlice, RandomAccessCollection {}

protocol MutableRandomAccessPartitioning: MutableBidirectionalPartitioning
where MutableSubSeq: MutableRandomAccessSlice {}

/// A collection which supports mutating its element and random access traversal mutable
protocol MutableRandomAccessCollection: MutableBidirectionalCollection, RandomAccessCollection
where
  MutableSubSeq: MutableRandomAccessSlice,
  MutableParts: MutableRandomAccessPartitioning
{}
