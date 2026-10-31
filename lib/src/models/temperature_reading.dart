/// Represents a temperature reading from the Ray Temp Blue device.
class TemperatureReading {
  /// The raw temperature value, expressed in [originalUnit] — the unit
  /// the thermometer was displaying when the reading was taken.
  ///
  /// Use [toCelsius], [toFahrenheit], [toKelvin] or [toUnit] to convert
  /// to a specific unit.
  final double value;

  /// The temperature unit of [value] — i.e. the device's current display
  /// unit at the moment of the reading.
  final TemperatureUnit originalUnit;

  /// The timestamp when the measurement was taken.
  final DateTime timestamp;

  /// Creates a new temperature reading.
  const TemperatureReading({
    required this.value,
    required this.originalUnit,
    required this.timestamp,
  });

  /// Converts the temperature to Celsius.
  double toCelsius() {
    switch (originalUnit) {
      case TemperatureUnit.celsius:
        return value;
      case TemperatureUnit.fahrenheit:
        return (value - 32) * 5 / 9;
    }
  }

  /// Converts the temperature to Fahrenheit.
  double toFahrenheit() {
    switch (originalUnit) {
      case TemperatureUnit.celsius:
        return (value * 9 / 5) + 32;
      case TemperatureUnit.fahrenheit:
        return value;
    }
  }

  /// Converts the temperature to Kelvin.
  double toKelvin() => toCelsius() + 273.15;

  /// Returns the temperature in [originalUnit] — same as [value].
  /// Kept for API compatibility; prefer reading [value] directly.
  double toOriginalUnit() => value;

  /// Returns the temperature converted to the requested [unit].
  double toUnit(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return toCelsius();
      case TemperatureUnit.fahrenheit:
        return toFahrenheit();
    }
  }

  @override
  String toString() {
    return 'TemperatureReading(value: ${value.toStringAsFixed(1)}'
           '${originalUnit.symbol}, originalUnit: $originalUnit, '
           'timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemperatureReading &&
        other.value == value &&
        other.originalUnit == originalUnit &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(value, originalUnit, timestamp);
}

/// Temperature units supported by the Ray Temp Blue device.
enum TemperatureUnit {
  /// Celsius (°C)
  celsius,
  
  /// Fahrenheit (°F)
  fahrenheit,
}

/// Extension to provide display names for temperature units.
extension TemperatureUnitExtension on TemperatureUnit {
  /// Returns the display symbol for the temperature unit.
  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
    }
  }

  /// Returns the display name for the temperature unit.
  String get displayName {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Celsius';
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit';
    }
  }
}
