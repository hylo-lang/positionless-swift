/// A slice obtained from `MutableRandomAccessCollection`.
protocol MutableRandomAccessSlice: MutableBidirectionalSlice, RandomAccessCollection {}

protocol MutableRandomAccessPartition: MutableBidirectionalPartition
where SubSeq: MutableRandomAccessSlice {}

/// A collection which supports mutating its element and random access traversal mutable
protocol MutableRandomAccessCollection: MutableBidirectionalCollection, RandomAccessCollection
where
  SubSeq: MutableRandomAccessSlice,
  Parts: MutableRandomAccessPartition
{}
