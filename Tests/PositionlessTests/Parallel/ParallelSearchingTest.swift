import Testing

@testable import Positionless

@Suite("parallelSplitFirst(where:)") struct ParallelSplitFirstWhere {

  @Test func multipleElementsSatisfyPredicate() {
    let array = [1, 2, 3, 4, 5]
    array.parallelSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1])
      #expect(p[part: 1] == [2, 3, 4, 5])
    }

    let array1 = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2]
    array1.parallelSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1, 1, 1, 1, 1, 1])
      #expect(p[part: 1] == [2, 2, 2, 2])
    }
  }

  @Test func noElementSatisfyPredicate() {
    let array = [1, 3, 5]
    array.parallelSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1, 3, 5])
      #expect(p[part: 1] == [])
    }
  }

  @Test func firstElementSatisfyPredicate() {
    let array = [2, 4, 6]
    array.parallelSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [2, 4, 6])
    }
  }

  @Test func emptyArray() {
    let array: [Int] = []
    array.parallelSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}

@Suite("parallelMutableSplitFirst(where:)") struct ParallelMutableSplitFirstWhere {

  @Test func multipleElementsSatisfyPredicate() {
    var array = [1, 2, 3, 4, 5]
    array.parallelMutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1])
      #expect(p[part: 1] == [2, 3, 4, 5])
    }
  }

  @Test func noElementSatisfyPredicate() {
    var array = [1, 3, 5]
    array.parallelMutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1, 3, 5])
      #expect(p[part: 1] == [])
    }
  }

  @Test func firstElementSatisfyPredicate() {
    var array = [2, 4, 6]
    array.parallelMutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [2, 4, 6])
    }
  }

  @Test func emptyArray() {
    var array: [Int] = []
    array.parallelMutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}
