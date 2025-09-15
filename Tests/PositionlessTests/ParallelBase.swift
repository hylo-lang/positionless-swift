import Testing

@testable import Positionless

private func isOdd(_ n: Int) -> Bool {
  return n % 2 == 1
}

@Suite("ParallelAlgorithmsBase") struct PartitioningChunk {
  @Test func immutableChunking() {
    let array = [2, 2, 3, 4, 5, 6]
    array.withParts(count: 4) { p in
      p.grow(part: 2, by: 3)
      p.transferAllToPrev(from: 2)
      p.withChunks(of: 2) { c in
        let cnt = c.count
        for i in 0..<cnt {
          c[i].grow(part: 0) { e in e % 2 == 1 }
        }
      }
      #expect(p[part: 0] == [2, 2])
      #expect(p[part: 1] == [3])
      #expect(p[part: 2] == [4])
      #expect(p[part: 3] == [5, 6])
    }
  }

  @Test func mutableChunks() {
    var array = [2, 2, 3, 4, 5, 6]
    array.withMutableParts(count: 4) { p in
      p.grow(part: 2, by: 3)
      p.transferAllToPrev(from: 2)
      p.withMutableChunks(of: 2) { c in
        let cnt = c.count
        for i in 0..<cnt {
          c[i].rotate()
        }
      }
      #expect(p[part: 0] == [2, 2, 3])
      #expect(p[part: 1] == [])
      #expect(p[part: 2] == [4, 5, 6])
      #expect(p[part: 3] == [])
    }
  }
}
