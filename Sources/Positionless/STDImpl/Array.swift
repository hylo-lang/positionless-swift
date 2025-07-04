extension Array: Collection {

  typealias Partition = ArrayPartition<Element>

  func isEmpty() -> Bool {
    isEmpty
  }

  var first: Element {
    _read {
      yield first!
    }
    _modify {
      var x = first!
      yield &x
    }
  }

  func withPartition<R>(
    count partitionCount: Int, _ f: (inout ArrayPartition<Element>) -> R
  ) -> R {
    var partition = ArrayPartition(self[...], into: partitionCount)
    return f(&partition)
  }

  mutating func withMutablePartition<R>(count partitionCount: Int, _ f: (inout Partition) -> R) -> R
  {
    var partition = ArrayPartition(self[...], into: partitionCount)
    let res = f(&partition)
    _writeBackArraySlice(from: partition.storage, to: &self[...])
    return res
  }

}
