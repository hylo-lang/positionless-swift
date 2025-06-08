import Testing

@testable import Positionless

@Test func whenFirstHalfIsEmpty() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  array.withMutablePartition(into: 2) { partition in
    partition.rotate()
    #expect(partition.partitionCount == 2)
    #expect(partition[part: 0].equals([1, 2, 3, 4, 5, 6, 7, 8, 9]))
    #expect(partition[part: 1].equals([]))
  }
}

@Test func whenSecondHalfIsEmpty() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  array.withMutablePartition(into: 2) { partition in
    partition.grow(part: 0, by: 9)
    partition.rotate()
    #expect(partition.partitionCount == 2)
    #expect(partition[part: 0].equals([]))
    #expect(partition[part: 1].equals([1, 2, 3, 4, 5, 6, 7, 8, 9]))
  }
}

@Test func whenFirstHalfIsSmaller() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  array.withMutablePartition(into: 2) { partition in
    partition.grow(part: 0, by: 3)
    partition.rotate()
    #expect(partition.partitionCount == 2)
    #expect(partition[part: 0].equals([4, 5, 6, 7, 8, 9]))
    #expect(partition[part: 1].equals([1, 2, 3]))
  }
}

@Test func whenFirstHalfIsLarger() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  array.withMutablePartition(into: 2) { partition in
    partition.grow(part: 0, by: 6)
    partition.rotate()
    #expect(partition.partitionCount == 2)
    #expect(partition[part: 0].equals([7, 8, 9]))
    #expect(partition[part: 1].equals([1, 2, 3, 4, 5, 6]))
  }
}

@Test func whenBothHalvesAreEqual() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8]
  array.withMutablePartition(into: 2) { partition in
    partition.grow(part: 0, by: 4)
    partition.rotate()
    #expect(partition.partitionCount == 2)
    #expect(partition[part: 0].equals([5, 6, 7, 8]))
    #expect(partition[part: 1].equals([1, 2, 3, 4]))
  }
}
