/// Copies element of `from` from every index `p` in `from` to index `p` in `to`.
///
/// - Precondition: `to` contains all indexes of `from`.
internal func _writeBackArraySlice<T>(from: ArraySlice<T>, to: inout ArraySlice<T>) {
  for i in from.indices {
    to[i] = from[i]
  }
}
