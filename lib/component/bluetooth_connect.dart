import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:new_flutter_project/component/bluetooth.dart';

import 'bluetooth_scan_devices.dart';

class BluetoothConnect extends StatefulWidget {
  @override
  _BluetoothConnectState createState() => _BluetoothConnectState();
}

class _BluetoothConnectState extends State<BluetoothConnect> {
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    bluetooth.state.then((value) => {
          setState(
            () {
              bluetoothState = value;
            },
          )
        });

    bluetooth.onStateChanged().listen((state) {
      setState(() {
        // Update the Bluetooth state
        bluetoothState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double deviceHeight = mediaQueryData.size.height;
    final double deviceWidth = mediaQueryData.size.width;
    const double padding = 0;

    final bluetoothStatusText =
        bluetoothState.isEnabled ? 'BLUETOOTH IS ON' : 'BLUETOOTH IS OFF';

    final appbarColor = bluetoothState.isEnabled ? Colors.blue : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('$bluetoothStatusText'),
        ),
        backgroundColor: appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: bluetoothState == BluetoothState.STATE_ON
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(children: [
                    Container(
                      width: deviceWidth,
                      height: deviceHeight,
                      color: Colors.blue,
                      child: const BluetoothScanDevices(),
                    ),
                  ]),
                ),
              )
            : const Center(
                child: Text(
                  'Please Open the bluetooth',
                  style: TextStyle(fontSize: 25),
                ),
              ),
      ),
    );
  }
}
