import Testing

@testable import Positionless

@Test func reverseOddLength() {
  var array = [1, 2, 3, 4, 5]
  array.reverse_()
  #expect(array == [5, 4, 3, 2, 1])
}

@Test func reverseEvenLength() {
  var array = [1, 2, 3, 4]
  array.reverse_()
  #expect(array == [4, 3, 2, 1])
}

@Test func reverseEmpty() {
  var array: [Int] = []
  array.reverse_()
  #expect(array == [])
}
