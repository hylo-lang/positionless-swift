import Foundation

/// An array whose shape can't be changed. Only elements are mutable.
struct FixedArray<Element> {

  struct UnsafeElementPointer<T>: @unchecked Sendable {
    public var pointer: UnsafeMutablePointer<T>

    public init(_ pointer: UnsafeMutablePointer<T>) {
      self.pointer = pointer
    }
  }

  /// Actual storage of elements.
  internal var storage: [Element]

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

  public mutating func parallelMutatingForEach(_ f: @escaping @Sendable (inout Element) -> Void) {
    let count = count
    storage.withUnsafeMutableBufferPointer { buffer in
      let base = UnsafeElementPointer.init(buffer.baseAddress!)
      let group = DispatchGroup()
      for i in 0..<count {
        group.enter()
        DispatchQueue.global().async {
          f(&base.pointer[i])
          group.leave()
        }
      }

      group.wait()
    }
  }
}

extension FixedArray: Sendable
where
  Element: Sendable
{
}
