import Testing

@testable import Positionless

@Test func rotate() {
  var array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  array.withMutablePartition(into: 2) { partition in
    partition.grow(part: 0, by: 3)
    partition.rotate()
    partition[part: 0].forEach { print($0) }
    print("---------")
    partition[part: 1].forEach { print($0) }
  }
}
