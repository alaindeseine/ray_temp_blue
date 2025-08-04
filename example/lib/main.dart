import 'package:flutter/material.dart';
import 'package:ray_temp_blue/ray_temp_blue.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ray Temp Blue Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ray Temp Blue Example'),
    );
  }
}

enum OperationMode {
  continuous,
  hold,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Mode selection
  OperationMode _selectedMode = OperationMode.hold;

  // Continuous mode instance
  RayTempBlue? _rayTempBlueContinuous;

  // HOLD mode instance
  RayTempBlueHold? _rayTempBlueHold;

  final TextEditingController _temperatureController = TextEditingController();

  List<RayTempDevice> _availableDevices = [];
  RayTempDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isMeasuring = false;

  String _statusMessage = 'Select operation mode and scan for devices';
  String? _lastKnownMacAddress;
  StreamSubscription<TemperatureReading>? _temperatureSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;
  Timer? _autoReconnectTimer;

  @override
  void initState() {
    super.initState();
    _initializeMode();
  }

  @override
  void dispose() {
    _temperatureSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _autoReconnectTimer?.cancel();
    _rayTempBlueContinuous?.dispose();
    _rayTempBlueHold?.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  void _initializeMode() {
    // Cancel previous subscriptions
    _connectionStatusSubscription?.cancel();
    _autoReconnectTimer?.cancel();

    if (_selectedMode == OperationMode.continuous) {
      _rayTempBlueContinuous = RayTempBlue();
      _rayTempBlueHold = null;
    } else {
      _rayTempBlueHold = RayTempBlueHold();
      _rayTempBlueContinuous = null;

      // Setup connection status monitoring for HOLD mode
      _connectionStatusSubscription = _rayTempBlueHold!.connectionStatusStream.listen(
        (isConnected) {
          setState(() {
            if (!isConnected && _selectedDevice != null) {
              _statusMessage = 'Connection lost. Attempting to reconnect...';
              _startAutoReconnect();
            }
          });
        },
      );
    }
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      if (_selectedMode == OperationMode.continuous) {
        await _rayTempBlueContinuous!.verifyPermissions();
      } else {
        await _rayTempBlueHold!.verifyPermissions();
      }
      setState(() {
        _statusMessage = 'Permissions granted. Ready to scan for devices.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Permission error: ${e.toString()}';
      });
    }
  }

  void _changeMode(OperationMode newMode) {
    if (_selectedDevice != null) {
      // Disconnect first if connected
      _disconnect();
    }

    setState(() {
      _selectedMode = newMode;
      _statusMessage = 'Mode changed. Ready to scan for devices.';
    });

    _initializeMode();
  }

  Future<void> _scanForDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for Ray Temp Blue devices...';
      _availableDevices.clear();
    });

    try {
      List<RayTempDevice> devices;
      if (_selectedMode == OperationMode.continuous) {
        devices = await _rayTempBlueContinuous!.scanDevices(
          timeout: const Duration(seconds: 10),
        );
      } else {
        devices = await _rayTempBlueHold!.scanDevices(
          timeout: const Duration(seconds: 10),
        );
      }

      setState(() {
        _availableDevices = devices;
        _statusMessage = devices.isEmpty
            ? 'No Ray Temp Blue devices found'
            : 'Found ${devices.length} device(s)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Scan error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(RayTempDevice device) async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to ${device.name}...';
    });

    try {
      if (_selectedMode == OperationMode.continuous) {
        await _rayTempBlueContinuous!.connect(device);

        // Start listening to continuous temperature readings
        _temperatureSubscription = _rayTempBlueContinuous!.temperatureStream.listen(
          (reading) {
            setState(() {
              _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
              _statusMessage = 'Connected (Continuous). Last reading: ${reading.timestamp.toString().substring(11, 19)}';
            });
          },
          onError: (error) {
            setState(() {
              _statusMessage = 'Temperature reading error: ${error.toString()}';
            });
          },
        );

        setState(() {
          _selectedDevice = device;
          _statusMessage = 'Connected to ${device.name} in Continuous mode. Temperature updates automatically.';
        });
      } else {
        await _rayTempBlueHold!.connect(device);

        // Start listening to manual temperature readings
        _temperatureSubscription = _rayTempBlueHold!.temperatureStream.listen(
          (reading) {
            setState(() {
              _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
              _statusMessage = 'Connected (HOLD). Last reading: ${reading.timestamp.toString().substring(11, 19)}';
              _isMeasuring = false;
            });
          },
          onError: (error) {
            setState(() {
              _statusMessage = 'Temperature reading error: ${error.toString()}';
              _isMeasuring = false;
            });
          },
        );

        setState(() {
          _selectedDevice = device;
          _lastKnownMacAddress = device.address;
          _statusMessage = 'Connected to ${device.name} in HOLD mode. If you see continuous readings, turn off/on the device to reset to HOLD mode.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnect() async {
    if (_selectedMode == OperationMode.continuous) {
      await _rayTempBlueContinuous!.disconnect();
    } else {
      await _rayTempBlueHold!.disconnect();
    }
    _temperatureSubscription?.cancel();
    _temperatureSubscription = null;

    setState(() {
      _selectedDevice = null;
      _statusMessage = 'Disconnected. Ready to scan for devices.';
      _temperatureController.clear();
      _isMeasuring = false;
    });
  }

  Future<void> _triggerMeasurement() async {
    if (_isMeasuring) return;

    setState(() {
      _isMeasuring = true;
      _statusMessage = 'Triggering measurement...';
    });

    try {
      if (_selectedMode == OperationMode.continuous) {
        await _rayTempBlueContinuous!.triggerMeasurement();
        setState(() {
          _statusMessage = 'Manual measurement triggered in continuous mode.';
        });
      } else {
        final reading = await _rayTempBlueHold!.triggerMeasurement();
        setState(() {
          _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
          _statusMessage = 'Manual measurement completed at ${reading.timestamp.toString().substring(11, 19)}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to trigger measurement: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isMeasuring = false;
      });
    }
  }

  Future<void> _identifyDevice() async {
    try {
      if (_selectedMode == OperationMode.continuous) {
        await _rayTempBlueContinuous!.identifyDevice();
      } else {
        await _rayTempBlueHold!.identifyDevice();
      }
      setState(() {
        _statusMessage = 'Device identification triggered (LEDs should flash)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to identify device: ${e.toString()}';
      });
    }
  }

  void _startAutoReconnect() {
    if (_selectedMode != OperationMode.hold || _lastKnownMacAddress == null) return;

    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _attemptAutoReconnect(),
    );
  }

  Future<void> _attemptAutoReconnect() async {
    if (_isConnecting || _rayTempBlueHold == null || _lastKnownMacAddress == null) return;

    try {
      setState(() {
        _statusMessage = 'Attempting to reconnect...';
      });

      await _rayTempBlueHold!.connectByMacAddress(_lastKnownMacAddress!);

      setState(() {
        _statusMessage = 'Reconnected successfully';
      });

      _autoReconnectTimer?.cancel();
    } catch (e) {
      // Reconnection failed, will try again in 10 seconds
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Mode selector with connection status
            Card(
              color: _selectedMode == OperationMode.continuous
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedMode == OperationMode.continuous
                                  ? Icons.play_circle_outline
                                  : Icons.pause_circle_outline,
                              size: 32,
                              color: _selectedMode == OperationMode.continuous
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedMode == OperationMode.continuous
                                  ? 'CONTINUOUS MODE'
                                  : 'HOLD MODE',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Connection status indicator
                        if (_selectedDevice != null)
                          Row(
                            children: [
                              Icon(
                                (_selectedMode == OperationMode.continuous && _rayTempBlueContinuous?.isConnected == true) ||
                                (_selectedMode == OperationMode.hold && _rayTempBlueHold?.isConnected == true)
                                    ? Icons.bluetooth_connected
                                    : Icons.bluetooth_disabled,
                                color: (_selectedMode == OperationMode.continuous && _rayTempBlueContinuous?.isConnected == true) ||
                                       (_selectedMode == OperationMode.hold && _rayTempBlueHold?.isConnected == true)
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (_selectedMode == OperationMode.continuous && _rayTempBlueContinuous?.isConnected == true) ||
                                (_selectedMode == OperationMode.hold && _rayTempBlueHold?.isConnected == true)
                                    ? 'Connected'
                                    : 'Disconnected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (_selectedMode == OperationMode.continuous && _rayTempBlueContinuous?.isConnected == true) ||
                                         (_selectedMode == OperationMode.hold && _rayTempBlueHold?.isConnected == true)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedMode == OperationMode.continuous
                          ? 'Automatic continuous temperature measurements'
                          : 'Manual measurements only (button press or trigger)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<OperationMode>(
                      segments: const [
                        ButtonSegment<OperationMode>(
                          value: OperationMode.hold,
                          label: Text('HOLD Mode'),
                          icon: Icon(Icons.pause_circle_outline),
                        ),
                        ButtonSegment<OperationMode>(
                          value: OperationMode.continuous,
                          label: Text('Continuous Mode'),
                          icon: Icon(Icons.play_circle_outline),
                        ),
                      ],
                      selected: {_selectedMode},
                      onSelectionChanged: (Set<OperationMode> newSelection) {
                        _changeMode(newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Temperature input field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temperature Reading',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _temperatureController,
                      decoration: InputDecoration(
                        labelText: _selectedMode == OperationMode.continuous
                            ? 'Temperature (Live)'
                            : 'Temperature (On Demand)',
                        border: const OutlineInputBorder(),
                        suffixText: '°C',
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Device connection section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Connection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_selectedDevice == null) ...[
                      ElevatedButton(
                        onPressed: _isScanning ? null : _scanForDevices,
                        child: _isScanning 
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Scanning...'),
                                ],
                              )
                            : const Text('Scan for Devices'),
                      ),
                      
                      if (_availableDevices.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Available Devices:'),
                        const SizedBox(height: 8),
                        ...(_availableDevices.map((device) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(device.name),
                            subtitle: Text('Serial: ${device.serialNumber}\nRSSI: ${device.rssi}dBm'),
                            trailing: ElevatedButton(
                              onPressed: _isConnecting ? null : () => _connectToDevice(device),
                              child: _isConnecting 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Connect'),
                            ),
                          ),
                        ))),
                      ],
                    ] else ...[
                      Text('Connected to: ${_selectedDevice!.name}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedMode == OperationMode.hold) ...[
                            ElevatedButton.icon(
                              onPressed: _isMeasuring ? null : _triggerMeasurement,
                              icon: _isMeasuring
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.thermostat),
                              label: const Text('Trigger Measurement'),
                            ),
                          ] else ...[
                            ElevatedButton.icon(
                              onPressed: _triggerMeasurement,
                              icon: const Icon(Icons.thermostat),
                              label: const Text('Manual Trigger'),
                            ),
                          ],
                          ElevatedButton.icon(
                            onPressed: _identifyDevice,
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Identify Device'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _disconnect,
                            icon: const Icon(Icons.bluetooth_disabled),
                            label: const Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedMode == OperationMode.continuous) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Temperature updates automatically in continuous mode',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Press device button or use "Trigger Measurement" for readings',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
