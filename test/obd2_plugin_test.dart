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

  setUp(() {

  });

  tearDown(() {

  });


  test('initBluetooth', () async {
    var obd = MockObd2Plugin();

    when(obd.isBluetoothEnable).thenAnswer((realInvocation) async => true);
    var isEnabled = await obd.isBluetoothEnable;
    verify(obd.isBluetoothEnable);
    expect(isEnabled, true);
  });

  test('Teste da função getConnection()', (){
    var device1 = BluetoothDevice(address: "00:11:22:33");
    //
  });
  
  test('Teste da função pairWithDevice()', () async {
    var device1 = BluetoothDevice(address: "00:11:22:33");

    when(ble.bondDeviceAtAddress(device1.address)).thenAnswer((_) => Future.value(true));

    bool result = await obd.pairWithDevice(device1);
    verify(ble.bondDeviceAtAddress(device1.address));
    expect(result, true);
  });

  test('Teste da função unpairWithDevice()', () async {
    var device1 = BluetoothDevice(address: "00:11:22:33");

    when(ble.removeDeviceBondWithAddress(device1.address)).thenAnswer((_) => Future.value(false));

    bool result = await obd.unpairWithDevice(device1);
    verify(ble.removeDeviceBondWithAddress(device1.address));
    expect(result, false);
  });

  test('Teste da função isPaired()', () async {
    var device1 = BluetoothDevice(address: "00:11:22:33");

    when(ble.getBondStateForAddress(device1.address)).thenAnswer((_) => Future.value(BluetoothBondState.bonded));
    var result = await obd.isPaired(device1);
    verify(ble.getBondStateForAddress(device1.address));
    expect(result, true);
  });
}
