import Testing

@testable import Positionless

@Test func equals() {
  var a1 = [1, 2, 3, 4, 5]
  var a2 = [1, 2, 3, 4, 5]
  #expect(a1.equals(a2), "Collections with equals should return true")

  a1 = [1, 2, 3, 4, 5]
  a2 = [1, 2, 3, 3, 5]
  #expect(!a1.equals(a2), "Collections with unequal elements should return false")

  a1 = [1, 2, 3, 4, 5]
  a2 = [1, 2, 3]
  #expect(!a1.equals(a2), "Collections with unequal number of elements should return false")

  a1 = [1, 2, 3]
  a2 = [1, 2, 3, 4, 5]
  #expect(!a1.equals(a2), "Collections with unequal number of elements should return false")

  a1 = []
  a2 = [1, 2, 3]
  #expect(!a1.equals(a2), "Collections with unequal number of elements should return false")

  a1 = [1, 2, 3]
  a2 = [0]
  #expect(!a1.equals(a2), "Collections with unequal number of elements should return false")
}
