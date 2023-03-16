import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Obd2Plugin {

  BluetoothConnection? connection;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final FlutterBluetoothSerial _bluetooth;
  Obd2Plugin(this._bluetooth);


  Future<BluetoothState> get initBluetooth async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    return _bluetoothState;
  }

  Future<bool> get enableBluetooth async {
    bool status = false;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      bool? newStatus = await FlutterBluetoothSerial.instance.requestEnable();
      if (newStatus != null && newStatus != false) {
        status = true;
      }
    } else {
      status = true;
    }
    return status;
  }

  Future<bool> get disableBluetooth async {
    bool status = false;
    if (_bluetoothState == BluetoothState.STATE_ON) {
      bool? newStatus = await FlutterBluetoothSerial.instance.requestDisable();
      if (newStatus != null && newStatus != false) {
        newStatus = true;
      }
    }
    return status;
  }

  Future<bool> get isBluetoothEnable async {
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      return false;
    } else if (_bluetoothState == BluetoothState.STATE_ON) {
      return true;
    } else {
      try {
        _bluetoothState = await initBluetooth;
        bool newStatus = await isBluetoothEnable;
        return newStatus;
      } catch (e) {
        throw Exception("obd2 plugin not initialed");
      }
    }
  }

  Future<List<BluetoothDevice>> get getPairedDevices async {
    return await _bluetooth.getBondedDevices();
  }

  Future<List<BluetoothDevice>> get getNearbyDevices async {
    List<BluetoothDevice> discoveryDevices = [];
    return await _bluetooth.startDiscovery().listen((event) {
      final existingIndex = discoveryDevices
          .indexWhere((element) => element.address == event.device.address);
      if (existingIndex >= 0) {
        discoveryDevices[existingIndex] = event.device;
      } else {
        if (event.device.name != null) {
          discoveryDevices.add(event.device);
        }
      }
    }).asFuture(discoveryDevices);
  }

  Future<List<BluetoothDevice>> get getNearbyPairedDevices async {
    List<BluetoothDevice> discoveryDevices = [];
    return await _bluetooth.startDiscovery().listen((event) async {
      final existingIndex = discoveryDevices
          .indexWhere((element) => element.address == event.device.address);
      if (existingIndex >= 0) {
        if (await isPaired(event.device)) {
          discoveryDevices[existingIndex] = event.device;
        }
      } else {
        if (event.device.name != null) {
          discoveryDevices.add(event.device);
        }
      }
    }).asFuture(discoveryDevices);
  }

  Future<List<BluetoothDevice>> get getNearbyAndPairedDevices async {
    List<BluetoothDevice> discoveryDevices =
    await _bluetooth.getBondedDevices();
    await _bluetooth.startDiscovery().listen((event) {
      final existingIndex = discoveryDevices
          .indexWhere((element) => element.address == event.device.address);
      if (existingIndex >= 0) {
        discoveryDevices[existingIndex] = event.device;
      } else {
        if (event.device.name != null) {
          discoveryDevices.add(event.device);
        }
      }
    }).asFuture(discoveryDevices);
    return discoveryDevices;
  }

  Future<void> getConnection(
      BluetoothDevice _device,
      Function(BluetoothConnection? connection) onConnected, //cria uma função chamada onConnected com uma variavel do tipo BluetoothConnection chamada connection
      Function(String message) onError) async {
    if (connection != null) { //se for diferente de null, aguarde até receber um resultado,se for null apenas pule
      await onConnected(connection);// connection é lá de cima
      return;
    }
    try {
      connection = await BluetoothConnection.toAddress(_device.address);
      if (connection != null) { //se for diferente de null, aguarde até receber um resultado,se for null apenas pule
        await onConnected(connection);
      } else {
        throw Exception(
            "Sorry this happened. But I can not connect to the device. But I guess the device is not nearby or you have not disconnected before. Finally, if you wants to enter into a new relationship, you must end his previous relationship");
      }//printa isso caso seja null
    } catch (e) {
      print(e);
    }
  }

  Future<bool> pairWithDevice(BluetoothDevice _device) async {
    bool paired = false;
    bool? isPaired = await _bluetooth.bondDeviceAtAddress(_device.address);
    if (isPaired != null) {
      paired = isPaired;
    }
    return paired;
  }

  Future<bool> unpairWithDevice(BluetoothDevice _device) async {
    bool unpaired = false;
    try {
      bool? isUnpaired =
      await _bluetooth.removeDeviceBondWithAddress(_device.address);
      if (isUnpaired != null) {
        unpaired = isUnpaired;
      }
    } catch (e) {
      unpaired = false;
    }
    return unpaired;
  }

  Future<bool> isPaired(BluetoothDevice _device) async {
    BluetoothBondState state =
    await _bluetooth.getBondStateForAddress(_device.address);
    return state.isBonded;
  }
}