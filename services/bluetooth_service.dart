import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? connection;
  List<BluetoothDevice> devices = [];

  Future<void> connectToDevice(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');
    } catch (e) {
      print('Cannot connect, exception occurred');
    }
  }

  Future<void> discoverDevices() async {
    devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    print('Found devices: ${devices.length}');
    for (var device in devices) {
      print('Device: ${device.name}, Address: ${device.address}');
    }
  }

  void startLogging(Function(String data) onDataReceived) {
    if (connection != null && connection!.isConnected) {
      connection!.input!.listen((data) {
        onDataReceived(String.fromCharCodes(data));
      });
    }
  }

  void stopLogging() {
    connection?.dispose();
    print('Logging stopped');
  }
}


