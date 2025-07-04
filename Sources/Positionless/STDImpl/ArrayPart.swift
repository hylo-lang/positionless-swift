/// A part of ArrayPartition.
struct ArrayPart<Element>: MutableCollection {

  /// Actual base storage of buffer.
  internal var storage: ArraySlice<Element>

  /// Creates instance of ArrayPart.
  public init(_ storage: ArraySlice<Element>) {
    self.storage = storage
  }

  typealias Element = Element

  typealias Partition = ArrayPartition<Element>

  func isEmpty() -> Bool {
    storage.isEmpty
  }

  var count: Int { storage.count }

  var first: Element {
    _read {
      yield storage.first!
    }
    _modify {
      yield &storage[storage.startIndex]
    }
  }

  func withPartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R {
    var partition = ArrayPartition(storage, into: partitionCount)
    return f(&partition)
  }

  mutating func withMutablePartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R
  {
    var partition = ArrayPartition(storage, into: partitionCount)
    let res = f(&partition)
    _writeBackArraySlice(from: partition.storage, to: &storage)
    return res
  }

}
