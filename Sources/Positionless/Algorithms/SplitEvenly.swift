/// Algorithms to make partitioning evenly distributed.
extension Partitioning {

  /// Makes the partitioning evenly distributed among non-empty parts with each
  /// non-empty part is preceeded by `gapCount` empty parts.
  ///
  /// - Precondition: `gapCount >= 0`.
  ///
  /// - Postcondition: If gaps can't be evenly distributed, then first non-empty
  /// part would have less gaps than `gapCount`.
  mutating func makeEvenlyDistributed(withGapsOf gapCount: Int = 0) {
    shiftSections(from: 0, to: partitionCount - 1)
    let numNonEmptyParts = (partitionCount + gapCount) / (gapCount + 1)
    var remainingElements = self[part: partitionCount - 1].count
    let partSize = remainingElements / numNonEmptyParts
    var numSmallerParts = numNonEmptyParts - (remainingElements % numNonEmptyParts)
    var i = partitionCount - 1
    while true {
      var curPartSize = partSize
      if numSmallerParts > 0 {
        numSmallerParts -= 1
      } else {
        curPartSize += 1
      }
      if curPartSize == remainingElements {
        break
      }
      remainingElements -= curPartSize
      grow(part: i - 1, by: remainingElements)
      shiftSections(from: i - 1, to: i - gapCount - 1)
      i -= gapCount - 1
    }
  }

}
