/// Slice obtained from `RandomAccessCollection`.
protocol RandomAccessSlice: BidirectionalSlice, RandomAccessCollection {}

/// Partition obtained from a `RandomAccessCollection`.
///
/// Gurarantees O(1) time for:
///   - `grow(part:, by:)`
///   - `shrink(part:, by:)`
protocol RandomAccessPartition: BidirectionalPartition
where SubSeq: RandomAccessSlice {}

/// Collection whose partition supports random-access to its elements.
///
/// Guarantees O(1) time for:
///   - `count`.
protocol RandomAccessCollection: BidirectionalCollection
where
  Parts: RandomAccessPartition,
  SubSeq: RandomAccessSlice
{

}
