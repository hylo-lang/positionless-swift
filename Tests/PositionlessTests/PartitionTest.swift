import Testing

@testable import Positionless

private func isOdd(_ n: Int) -> Bool {
  return n % 2 == 1
}

@Suite("halfStablePartition(by:)") struct HalfStablePartition {

  @Test func whenBothPartsHaveSomeElements() {
    var array = [1, 2, 3, 4, 5, 6]
    array.halfStablePartition(by: isOdd) { p in
      #expect(p[part: 0] == [2, 4, 6])
      #expect(p[part: 1].all(satisfy: isOdd))
    }
  }

  @Test func whenFirstPartIsEmpty() {
    var array = [1, 3, 5]
    array.halfStablePartition(by: isOdd) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1].all(satisfy: isOdd))
    }
  }

  @Test func whenSecondPartIsEmpty() {
    var array = [2, 4, 6]
    array.halfStablePartition(by: isOdd) { p in
      #expect(p[part: 0] == [2, 4, 6])
      #expect(p[part: 1].all(satisfy: isOdd))
    }
  }

  @Test func whenBothPartsAreEmpty() {
    var array: [Int] = []
    array.halfStablePartition(by: isOdd) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1].all(satisfy: isOdd))
    }
  }

}
