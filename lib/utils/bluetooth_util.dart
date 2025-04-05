import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class BleUtil {
  final String mountedLock = "black lock demo";
  final String tableTopLock = "PCB_NoSpeaker";
  final _foundDevices = <String, ScanResult>{}; // Store devices
  final Map<String, BluetoothDevice> _cachedDevices = {};
  final Map<String, BluetoothDevice> _connectedDevicesCache =
      {}; // Cache for connected devices

  void getPermissions() async {
    List<Permission> permissions = [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.ignoreBatteryOptimizations,
    ];
    await permissions.request();
  }

  void findBleState() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
      } else {}
    });

    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    subscription.cancel();
  }

  Stream<List<ScanResult>> scanedDevices() async* {
    Set<ScanResult> uniqueResultsSet = {};

    await for (var results in FlutterBluePlus.onScanResults) {
      if (results.isNotEmpty) {
        for (var result in results) {
          if (result.device.name != null &&
              result.device.name.isNotEmpty &&
              result.advertisementData.connectable) {
            _cachedDevices[result.device.remoteId.id] =
                result.device; // Cache device

            _foundDevices[result.device.id.id] = result;

            uniqueResultsSet.add(result);
          }
        }
        yield uniqueResultsSet.toList();
      } else {
        yield [];
      }
    }
  }

  void startScan() async {
    // listen to scan results
// Note: `onScanResults` clears the results between scans. You should use
//  `scanResults` if you want the current scan results *or* the results from the previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        }
      },
      onError: (e) => print(e),
    );

// cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
        continuousUpdates: true,
        continuousDivisor: 1,
        withNames: [mountedLock]).catchError((error) {
      print("Error starting scan: $error");
    });

// wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  Future<bool> connectToDevice(String bleAddress) async {
    try {
      // Check if the device is already connected and cached
      if (_connectedDevicesCache.containsKey(bleAddress)) {
        print('Using cached connection for $bleAddress');
        return true;
      }

      final device = _cachedDevices[bleAddress] ??
          BluetoothDevice(remoteId: DeviceIdentifier(bleAddress));

      await device.connect(autoConnect: false);
      await Future.delayed(Duration(milliseconds: 50));
      await device.requestConnectionPriority(
          connectionPriorityRequest: ConnectionPriority.high);
      await device.requestMtu(512);

      print('Connected to $bleAddress');

      // Cache the connected device
      _connectedDevicesCache[bleAddress] = device;

      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  Future<void> disconnectFromDevice(String bleAddress) async {
    final device = _connectedDevicesCache[bleAddress] ??
        BluetoothDevice(remoteId: DeviceIdentifier(bleAddress));
    try {
      await device.disconnect();
      print('Disconnected from $bleAddress');

      // Remove the device from the cache
      _connectedDevicesCache.remove(bleAddress);
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }

  Future<void> sendData(BluetoothDevice device, dynamic data) async {
    try {
      dynamic dataToSend = data;
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          try {
            if (c.properties.write) {
              List<int> data = utf8.encode(dataToSend);
              await c.write(data, withoutResponse: false);
              print('Object written');
            }
          } catch (e) {
            print('$e during writing');
          }
        }
      }
    } catch (e) {
      print('Error occurred while writing - $e');
    }
  }

  void readData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.onValueReceived.listen((value) {
              // Process and print the received data
              print("Read value: ${utf8.decode(value)}");
            });
          } else if (characteristic.properties.read) {
            try {
              List<int> value = await characteristic.read();
              print("Read value: ${utf8.decode(value)}");
            } catch (e) {
              print("Failed to read characteristic: $e");
            }
          }
        }
      }
    } catch (e) {
      print('Error occurred while reading - $e');
    }
  }
}
