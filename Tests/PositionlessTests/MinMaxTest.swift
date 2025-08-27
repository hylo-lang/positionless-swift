import Testing

@testable import Positionless

@Suite("splitBeforeMaxElement(by: )") struct MaxElementBy {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    arr.splitBeforeMaxElement(by: { $0 < $1 }) { p in
      #expect(p[part: 0] == [8, 1, 2, 4])
      #expect(p[part: 1] == [8, 3, 5])
    }
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    arr.splitBeforeMaxElement(by: { $0 < $1 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}

@Suite("splitBeforeMinElement(by: )") struct MinElementBy {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 2, 1, 4, 1, 3, 5]
    arr.splitBeforeMinElement(by: { $0 < $1 }) { p in
      #expect(p[part: 0] == [8, 2])
      #expect(p[part: 1] == [1, 4, 1, 3, 5])
    }
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    arr.splitBeforeMinElement(by: { $0 < $1 }) { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}

@Suite("splitBeforeMaxElement()") struct MaxElement {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    arr.splitBeforeMaxElement { p in
      #expect(p[part: 0] == [8, 1, 2, 4])
      #expect(p[part: 1] == [8, 3, 5])
    }
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    arr.splitBeforeMaxElement { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}

@Suite("splitBeforeMinElement()") struct MinElement {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 2, 1, 4, 1, 3, 5]
    arr.splitBeforeMinElement { p in
      #expect(p[part: 0] == [8, 2])
      #expect(p[part: 1] == [1, 4, 1, 3, 5])
    }
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    arr.splitBeforeMinElement { p in
      #expect(p[part: 0] == [])
      #expect(p[part: 1] == [])
    }
  }

}
