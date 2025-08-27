/// An array whose shape can't be changed. Only elements are mutable.
struct FixedArray<Element> {
  /// Actual storage of elements.
  private var storage: [Element]

  /// Creates an instance from given array.
  public init(_ storage: [Element]) {
    self.storage = storage
  }

  /// Number of elements in array.
  public var count: Int { storage.count }

  /// First element
  public var first: Element? { storage.first }

  /// Last element
  public var last: Element? { storage.last }

  /// Access individual elements.
  public subscript(index: Int) -> Element {
    get { storage[index] }
    set { storage[index] = newValue }
  }
}
