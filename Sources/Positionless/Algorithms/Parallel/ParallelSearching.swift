import Foundation

extension Partitioning
where
  Self.SubSeq: Sendable
{

  /// Grows part 0 until first element of next part satisfies `predicate` or becomes empty.
  ///
  /// - Precondition: `partitionCount == 2`.
  ///
  /// - Complexity: No more than `self[part: 0].count` to `grow`.
  mutating func parallelGrowFirst(until predicate: @escaping @Sendable (SubSeq.Element) -> Bool) {
    let hardwareConcurrency = ProcessInfo.processInfo.activeProcessorCount

    let totalPartsRequired = hardwareConcurrency * 2
    let additionalPartsRequired = totalPartsRequired - partitionCount

    withAdditionalParts(additionalPartsRequired) { p in
      p.makeEvenlyDistributed(withGapsOf: 1)

      p.withChunks(of: 2) {
        $0.parallelMutatingForEach {
          $0.grow(part: 0, until: predicate)
        }
      }

      var found = false
      for i in stride(from: 0, to: totalPartsRequired, by: 2) {
        if !p[part: i + 1].isEmpty() {
          found = true
          p.shiftSections(from: i, to: 0)
          p.shiftSections(from: totalPartsRequired - 1, to: 1)
          break
        }
      }

      if !found {
        p.shiftSections(from: totalPartsRequired - 1, to: 0)
      }

    }
  }

}

extension Collection
where SubSeq: Sendable {

  /// Splits the collection at the first element that satisfies the given predicate.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  func parallelSplitFirst<R>(
    where predicate: @Sendable @escaping (Element) -> Bool,
    _ f: (inout Parts) -> R
  ) -> R {
    return withParts(count: 2) { p in
      p.parallelGrowFirst(until: predicate)
      return f(&p)
    }
  }

}

extension MutableCollection
where SubSeq: Sendable {

  /// Splits the collection at the first element that satisfies the given predicate.
  ///
  /// - Postcondition:
  ///   - `part[0]` contains all elements before the first match.
  ///   - `part[1]` contains the first matching element and all elements after it.
  ///
  /// - Complexity: O(`count`).
  mutating func parallelMutableSplitFirst<R>(
    where predicate: @escaping @Sendable (Element) -> Bool,
    _ f: (inout MutableParts) -> R
  )
    -> R
  {
    return withMutableParts(count: 2) { p in
      p.parallelGrowFirst(until: predicate)
      return f(&p)
    }
  }

}
