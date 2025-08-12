/// Copies every element of `from` to `to` for all indexes of `to`.
///
/// - Precondition: `to` contains all indexes of `from`.
internal func _writeBackElements<C1, C2>(from: C1, to: inout C2)
where
  C1: Swift.Collection,
  C2: Swift.MutableCollection,
  C1.Element == C2.Element,
  C1.Index == C2.Index
{
  for i in to.indices {
    to[i] = from[i]  // assuming no bounds check
  }
}
