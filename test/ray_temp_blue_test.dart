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

    test('should convert Celsius to Fahrenheit correctly', () {
      final reading = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );

      expect(reading.toFahrenheit(), 77.0);
    });

    test('should convert Celsius to Kelvin correctly', () {
      final reading = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );

      expect(reading.toKelvin(), 298.15);
    });

    test('should return original value for toCelsius', () {
      final reading = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );

      expect(reading.toCelsius(), 25.0);
    });

    test('should return correct original unit value', () {
      final celsiusReading = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.now(),
      );

      final fahrenheitReading = TemperatureReading(
        value: 25.0,
        originalUnit: TemperatureUnit.fahrenheit,
        timestamp: DateTime.now(),
      );

      expect(celsiusReading.toOriginalUnit(), 25.0);
      expect(fahrenheitReading.toOriginalUnit(), 77.0);
    });

    test('should have correct string representation', () {
      final reading = TemperatureReading(
        value: 25.5,
        originalUnit: TemperatureUnit.celsius,
        timestamp: DateTime.parse('2024-01-01 12:00:00'),
      );

      expect(reading.toString(), contains('25.5°C'));
      expect(reading.toString(), contains('celsius'));
      expect(reading.toString(), contains('2024-01-01'));
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
