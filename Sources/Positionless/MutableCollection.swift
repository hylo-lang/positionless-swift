/// Mutable partitions of collection.
protocol MutableCollectionPartition: CollectionPartition
where Part: MutableCollection {

  /// Swaps first element partition i and j.
  ///
  /// - Precondition: `i >= 0 && j >= 0 && i < partitionCount && j < partitionCount`.
  mutating func swapFirst(_ i: Int, _ j: Int)

}

/// A collection that supports mutation of elements.
protocol MutableCollection: Collection
where Partition: MutableCollectionPartition {

  /// The first element of the collection.
  ///
  /// - Precondition: !self.isEmpty()
  var first: Element { get set }

}
