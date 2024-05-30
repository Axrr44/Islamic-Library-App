class IndexDropdownItem {
  final String name;
  final int index;

  IndexDropdownItem(this.name, this.index);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IndexDropdownItem && other.name == name && other.index == index;
  }

  @override
  int get hashCode => name.hashCode ^ index.hashCode;

  @override
  String toString() => name;
}
