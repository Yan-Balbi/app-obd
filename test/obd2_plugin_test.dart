import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:teste_software3/obd2_plugin.dart';

import 'obd2_plugin_test.mocks.dart';

@GenerateMocks([FlutterBluetoothSerial, Obd2Plugin])

class MockBluetoothConnection extends Mock implements BluetoothConnection{}

void main() {

  const MethodChannel channel = MethodChannel('obd2_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  var ble = MockFlutterBluetoothSerial();
  var obd = Obd2Plugin(ble);

  group('Bluetooth tests', (){

    setUp(() {
      print('Inicializando teste');
    });

    tearDown(() {
  print('Destruindo teste');
    });

    setUpAll((){
      print('Iniciando o suit');
    });

    tearDownAll((){
      print('Finalizando o suit');
    });

    test('initBluetooth', () async {
      print('Executando teste initBluetooth()');
      var obd = MockObd2Plugin();

      when(obd.isBluetoothEnable).thenAnswer((realInvocation) async => true);
      var isEnabled = await obd.isBluetoothEnable;
      verify(obd.isBluetoothEnable);
      expect(isEnabled, true);
    });


    test('Teste da função pairWithDevice()', () async {
      print('Executando teste pairWithDevice()');
      var device1 = BluetoothDevice(address: "00:11:22:33");

      when(ble.bondDeviceAtAddress(device1.address)).thenAnswer((_) => Future.value(true));

      bool result = await obd.pairWithDevice(device1);
      verify(ble.bondDeviceAtAddress(device1.address));
      expect(result, true);
    });

    test('Teste da função unpairWithDevice()', () async {
      print('Executando teste unpairWithDevice()');
      var device1 = BluetoothDevice(address: "00:11:22:33");

      when(ble.removeDeviceBondWithAddress(device1.address)).thenAnswer((_) => Future.value(false));

      bool result = await obd.unpairWithDevice(device1);
      verify(ble.removeDeviceBondWithAddress(device1.address));
      expect(result, false);
    });

    test('Teste da função isPaired()', () async {
      print('Executando teste isPaired()');
      var device1 = BluetoothDevice(address: "00:11:22:33");

      when(ble.getBondStateForAddress(device1.address)).thenAnswer((_) => Future.value(BluetoothBondState.bonded));
      var result = await obd.isPaired(device1);
      verify(ble.getBondStateForAddress(device1.address));
      expect(result, true);
    });
  });

  group('Vin conversion tests', () {
    setUp((){
      print('Iniciando teste');
    });

    tearDown((){
      print('Destruindo teste');
    });

    setUpAll((){
      print('Iniciando o suit');
    });

    tearDownAll((){
      print('Finalizando o suit');
    });

    test('Decode VIN', () {
      print('Executando teste decodeVIN()');
      var payload =
      '''
    >0902
    49 02 01 00 00 00 31
    49 02 02 44 34 47 50
    49 02 03 30 30 52 35
    49 02 04 35 42 31 32
    49 02 05 33 34 35 36''';
      expect(obd.decodeVIN(payload), equals('1D4GP00R55B123456'));
    });

    test('Decode VIN CAN', () {
      print('Executando teste decodeVINCAN()');
      var payload =
      '''
    >0902
    014
    0: 49 02 01 31 44 34
    1: 47 50 30 30 52 35 35
    2: 42 31 32 33 34 35 36''';
      expect(obd.decodeVINCAN(payload), equals('1D4GP00R55B123456'));

    });
  });
}
