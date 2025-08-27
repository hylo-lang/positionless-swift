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

@Suite("max(by: )") struct MaxBy {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    #expect(arr.max_(by: { $0 < $1 }) == 8)
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    #expect(arr.max_(by: { $0 < $1 }) == nil)
  }

}

@Suite("min(by: )") struct MinBy {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    #expect(arr.min_(by: { $0 < $1 }) == 1)
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    #expect(arr.min_(by: { $0 < $1 }) == nil)
  }

}

@Suite("max()") struct Max {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    #expect(arr.max_() == 8)
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    #expect(arr.max_() == nil)
  }

}

@Suite("min()") struct Min {

  @Test func whenThereExistsMultipleMaxElements() {
    let arr = [8, 1, 2, 4, 8, 3, 5]
    #expect(arr.min_() == 1)
  }

  @Test func forEmptyCollection() {
    let arr: [Int] = []
    #expect(arr.min_() == nil)
  }

}
