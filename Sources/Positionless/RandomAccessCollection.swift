/// Partitioning for RandomAccessCollection
///
/// It guarantees that `grow(part: , by: )` and `shrink(part: , by: )` works
/// in O(1).
protocol RandomAccessCollectionPartition: BidirectionalCollectionPartition
where Part: RandomAccessCollection {
}

/// Collection that supports efficient element jumps while traversal.
protocol RandomAccessCollection: BidirectionalCollection {
}
