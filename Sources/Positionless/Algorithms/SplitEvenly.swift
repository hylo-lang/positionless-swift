/// Algorithms to split the collection evenly.
extension Collection {

  /// Splits `self` evenly into `parts` non-empty segments, inserting `gapCount`
  /// empty slots before each segment, and calls `f` with that partitioning.
  /// After that call `projectionFn` with partitioning of size `prefixCount`.
  ///
  /// - Precondition: `parts * (gapCount + 1) >= projectPrefix`.
  func withPrefixPartsOfSplittingEvenly<R>(
    in parts: Int, gaps gapCount: Int, projectPrefix prefixCount: Int,
    _ projectionFn: (inout Parts) -> R, _ f: (inout Parts) -> Void
  ) -> R {
    let numElements = count
    return withParts(count: prefixCount) {
      let currentParts = $0.partitionCount
      let totalParts = parts * (gapCount + 1)
      let additionalParts = totalParts - currentParts
      $0.withAdditionalParts(additionalParts) { p in
        p.shiftSections(from: currentParts - 1, to: totalParts - 1)
        let partSize = numElements / totalParts
        var numSmallerParts = totalParts - (numElements % totalParts)
        var remainingElements = numElements
        var i = totalParts - 1
        while i >= 0 {
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
          p.grow(part: i - 1, by: remainingElements)
          p.shiftSections(from: i - 1, to: i - gapCount - 1)
          i = i - gapCount - 1
        }
        f(&p)
      }
      return projectionFn(&$0)
    }
  }

}
