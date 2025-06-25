class ManualExpense {
  final String name;
  final double value;

  const ManualExpense({
    required this.name,
    required this.value,
  });

  // Convert object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  // Create object from Map (database retrieval)
  factory ManualExpense.fromMap(Map<String, dynamic> map) {
    return ManualExpense(
      name: map['name'] as String,
      value: map['value'] as double,
    );
  }

  // For creating copies with modified values
  ManualExpense copyWith({
    String? name,
    double? value,
  }) {
    return ManualExpense(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  // Override equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ManualExpense && other.name == name && other.value == value;
  }

  // Override hash code
  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  // For better debugging representation
  @override
  String toString() => 'ManualExpense(name: $name, value: $value)';
}
