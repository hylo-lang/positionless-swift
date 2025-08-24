import Testing

@testable import Positionless

@Suite("splitFirst(where:)") struct SplitFirstWhere {

  @Test func multipleElementsSatisfyPredicate() {
    let array = [1, 2, 3, 4, 5]
    array.splitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1])
      #expect(p[part: 1] == [2, 3, 4, 5])
    }
  }

  @Test func noElementSatisfyPredicate() {
    let array = [1, 3, 5]
    array.splitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1, 3, 5])
      #expect(p[part: 1] == [])
    }
  }

  @Test func allElementsSatisfyPredicate() {
    let array = [2, 4, 6]
    array.splitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [2, 4, 6])
    }
  }

  @Test func emptyArray() {
    let array: [Int] = []
    array.splitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}

@Suite("mutableSplitFirst(where:)") struct SplitFirstMutWhere {

  @Test func multipleElementsSatisfyPredicate() {
    var array = [1, 2, 3, 4, 5]
    array.mutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1])
      #expect(p[part: 1] == [2, 3, 4, 5])
    }
  }

  @Test func noElementSatisfyPredicate() {
    var array = [1, 3, 5]
    array.mutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [1, 3, 5])
      #expect(p[part: 1] == [])
    }
  }

  @Test func allElementsSatisfyPredicate() {
    var array = [2, 4, 6]
    array.mutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [2, 4, 6])
    }
  }

  @Test func emptyArray() {
    var array: [Int] = []
    array.mutableSplitFirst(where: { $0 % 2 == 0 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}
