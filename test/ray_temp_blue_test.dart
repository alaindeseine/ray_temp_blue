import 'package:flutter_test/flutter_test.dart';
import 'package:ray_temp_blue/ray_temp_blue.dart';

void main() {
  group('TemperatureReading', () {
    test('should create temperature reading correctly', () {
      final timestamp = DateTime.now();
      final reading = TemperatureReading(
        value: 25.5,
        originalUnit: TemperatureUnit.celsius,
        timestamp: timestamp,
      );

      expect(reading.value, 25.5);
      expect(reading.originalUnit, TemperatureUnit.celsius);
      expect(reading.timestamp, timestamp);
    });

    test('toFahrenheit converts correctly from both source units', () {
      final celsius = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );
      expect(celsius.toFahrenheit(), 77.0);

      final fahrenheit = TemperatureReading(
        value: 77.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );
      expect(fahrenheit.toFahrenheit(), 77.0);
    });

    test('toCelsius converts correctly from both source units', () {
      final celsius = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );
      expect(celsius.toCelsius(), 25.0);

      final fahrenheit = TemperatureReading(
        value: 77.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );
      expect(fahrenheit.toCelsius(), closeTo(25.0, 1e-9));
    });

    test('toKelvin converts correctly from both source units', () {
      final celsius = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );
      expect(celsius.toKelvin(), 298.15);

      final fahrenheit = TemperatureReading(
        value: 77.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );
      expect(fahrenheit.toKelvin(), closeTo(298.15, 1e-9));
    });

    test('toOriginalUnit returns value as-is', () {
      final celsius = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );
      final fahrenheit = TemperatureReading(
        value: 75.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );

      expect(celsius.toOriginalUnit(), 25.0);
      expect(fahrenheit.toOriginalUnit(), 75.0);
    });

    test('toString uses the originalUnit symbol', () {
      final celsius = TemperatureReading(
        value: 25.5,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.parse('2024-01-01 12:00:00'),
      );
      expect(celsius.toString(), contains('25.5°C'));
      expect(celsius.toString(), contains('celsius'));
      expect(celsius.toString(), contains('2024-01-01'));

      final fahrenheit = TemperatureReading(
        value: 75.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.parse('2024-01-01 12:00:00'),
      );
      expect(fahrenheit.toString(), contains('75.0°F'));
      expect(fahrenheit.toString(), contains('fahrenheit'));
    });

    test('toUnit converts correctly in both directions', () {
      final celsius = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );
      expect(celsius.toUnit(TemperatureUnit.celsius), 25.0);
      expect(celsius.toUnit(TemperatureUnit.fahrenheit), 77.0);

      final fahrenheit = TemperatureReading(
        value: 75.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );
      expect(fahrenheit.toUnit(TemperatureUnit.celsius),
          closeTo(23.888888, 1e-5));
      expect(fahrenheit.toUnit(TemperatureUnit.fahrenheit), 75.0);
    });

    test('should implement equality correctly', () {
      final timestamp = DateTime.now();
      final reading1 = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: timestamp,
      );
      final reading2 = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: timestamp,
      );
      final reading3 = TemperatureReading(
        value: 26.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: timestamp,
      );

      expect(reading1, equals(reading2));
      expect(reading1, isNot(equals(reading3)));
    });
  });

  group('TemperatureUnit', () {
    test('should have correct symbols', () {
      expect(TemperatureUnit.celsius.symbol, '°C');
      expect(TemperatureUnit.fahrenheit.symbol, '°F');
    });

    test('should have correct display names', () {
      expect(TemperatureUnit.celsius.displayName, 'Celsius');
      expect(TemperatureUnit.fahrenheit.displayName, 'Fahrenheit');
    });
  });

  group('RayTempBlue / RayTempBlueHold constructors', () {
    test('RayTempBlue instantiates without preferredUnit', () {
      final instance = RayTempBlue();
      expect(instance.isConnected, false);
      expect(instance.deviceUnit, TemperatureUnit.celsius);
    });

    test('RayTempBlue instantiates with preferredUnit', () {
      final instance = RayTempBlue(preferredUnit: TemperatureUnit.fahrenheit);
      expect(instance.isConnected, false);
    });

    test('RayTempBlueHold instantiates without preferredUnit', () {
      final instance = RayTempBlueHold();
      expect(instance.isConnected, false);
      expect(instance.deviceUnit, TemperatureUnit.celsius);
    });

    test('RayTempBlueHold instantiates with preferredUnit', () {
      final instance = RayTempBlueHold(preferredUnit: TemperatureUnit.fahrenheit);
      expect(instance.isConnected, false);
    });
  });

  group('RayTempDevice', () {
    test('should extract serial number correctly', () {
      expect(RayTempDevice.extractSerialNumber('12345678 RayTempBlue'), '12345678');
      expect(RayTempDevice.extractSerialNumber('87654321 ThermaQBlue'), '87654321');
      expect(RayTempDevice.extractSerialNumber('InvalidName'), 'Unknown');
    });

    test('should identify Ray Temp Blue devices correctly', () {
      expect(RayTempDevice.isRayTempBlue('12345678 RayTempBlue'), true);
      expect(RayTempDevice.isRayTempBlue('12345678 raytemp blue'), true);
      expect(RayTempDevice.isRayTempBlue('12345678 ThermaQBlue'), false);
      expect(RayTempDevice.isRayTempBlue('SomeOtherDevice'), false);
    });
  });

  group('RayTempExceptions', () {
    test('should create permission exception correctly', () {
      final exception = RayTempPermissionException(
        'Missing permissions',
        ['BLUETOOTH_SCAN', 'BLUETOOTH_CONNECT'],
      );

      expect(exception.message, 'Missing permissions');
      expect(exception.missingPermissions, ['BLUETOOTH_SCAN', 'BLUETOOTH_CONNECT']);
      expect(exception.toString(), contains('BLUETOOTH_SCAN'));
      expect(exception.toString(), contains('BLUETOOTH_CONNECT'));
    });

    test('should create connection exception correctly', () {
      final exception = RayTempConnectionException(
        'Connection failed',
        '00:11:22:33:44:55',
      );

      expect(exception.message, 'Connection failed');
      expect(exception.deviceAddress, '00:11:22:33:44:55');
      expect(exception.toString(), contains('00:11:22:33:44:55'));
    });

    test('should create sensor exception correctly', () {
      final exception = RayTempSensorException(
        'Sensor error',
        0xFFFFFFFF,
      );

      expect(exception.message, 'Sensor error');
      expect(exception.errorCode, 0xFFFFFFFF);
      expect(exception.toString(), contains('FFFFFFFF'));
    });

    test('should create service exception correctly', () {
      final exception = RayTempServiceException(
        'Service not found',
        '455449424C5545544845524DB87AD700',
      );

      expect(exception.message, 'Service not found');
      expect(exception.uuid, '455449424C5545544845524DB87AD700');
      expect(exception.toString(), contains('455449424C5545544845524DB87AD700'));
    });

    test('should create data exception correctly', () {
      final exception = RayTempDataException(
        'Invalid data',
        [0x01, 0x02, 0x03],
      );

      expect(exception.message, 'Invalid data');
      expect(exception.rawData, [0x01, 0x02, 0x03]);
      expect(exception.toString(), contains('[1, 2, 3]'));
    });
  });
}
