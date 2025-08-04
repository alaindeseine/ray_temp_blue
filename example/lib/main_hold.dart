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
      title: 'Ray Temp Blue HOLD Mode Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ray Temp Blue HOLD Mode'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RayTempBlueHold _rayTempBlue = RayTempBlueHold();
  final TextEditingController _temperatureController = TextEditingController();
  
  List<RayTempDevice> _availableDevices = [];
  RayTempDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isMeasuring = false;
  String _statusMessage = 'Ready to scan for devices';
  StreamSubscription<TemperatureReading>? _temperatureSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _temperatureSubscription?.cancel();
    _rayTempBlue.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      await _rayTempBlue.verifyPermissions();
      setState(() {
        _statusMessage = 'Permissions granted. Ready to scan for devices.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Permission error: ${e.toString()}';
      });
    }
  }

  Future<void> _scanForDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for Ray Temp Blue devices...';
      _availableDevices.clear();
    });

    try {
      final devices = await _rayTempBlue.scanDevices(
        timeout: const Duration(seconds: 10),
      );
      
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
      await _rayTempBlue.connect(device);
      
      // Start listening to temperature readings (only when button pressed)
      _temperatureSubscription = _rayTempBlue.temperatureStream.listen(
        (reading) {
          setState(() {
            _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
            _statusMessage = 'Connected in HOLD mode. Last reading: ${reading.timestamp.toString().substring(11, 19)}';
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
        _statusMessage = 'Connected to ${device.name} in HOLD mode. Press device button or trigger measurement manually.';
      });
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
    await _rayTempBlue.disconnect();
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
      final reading = await _rayTempBlue.triggerMeasurement();
      setState(() {
        _temperatureController.text = '${reading.value.toStringAsFixed(1)}°C';
        _statusMessage = 'Manual measurement completed at ${reading.timestamp.toString().substring(11, 19)}';
      });
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
      await _rayTempBlue.identifyDevice();
      setState(() {
        _statusMessage = 'Device identification triggered (LEDs should flash)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to identify device: ${e.toString()}';
      });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode indicator
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.pause_circle_outline, size: 48, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text(
                      'HOLD MODE',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Measurements only when button pressed or manually triggered',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
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
                      decoration: const InputDecoration(
                        labelText: 'Temperature (°C)',
                        border: OutlineInputBorder(),
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
    );
  }
}
