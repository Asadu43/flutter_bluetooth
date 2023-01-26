import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothDeviceListEntry.dart';
import 'bluetooth.dart';

class BluetoothScanDevices extends StatefulWidget {
  const BluetoothScanDevices({super.key});

  @override
  BluetoothScanDevicesState createState() => BluetoothScanDevicesState();
}

class BluetoothScanDevicesState extends State<BluetoothScanDevices> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);

  bool isDiscovering = true;

  @override
  void initState() {
    super.initState();

    if (isDiscovering) {
      _startDiscovery();
    }
  }

  // device restart func
  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
      print('restart scan');
    });

    _startDiscovery();
  }

// device scaning start func
  void _startDiscovery() {
    _streamSubscription = bluetooth.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

// device stop scaning func
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, index) {
        BluetoothDiscoveryResult result = results[index];
        final device = result.device;
        final address = device.address;
        return BluetoothDeviceListEntry(
          device: device,
          rssi: result.rssi,
          onTap: () {
            // Navigator.of(context).pop(result.device);
          },
          onLongPress: () async {
            try {
              bool bonded = false;
              if (device.isBonded) {
                print('Unbonding from ${device.address}...');
                await FlutterBluetoothSerial.instance
                    .removeDeviceBondWithAddress(address);
                print('Unbonding from ${device.address} has succed');
              } else {
                print('Bonding with ${device.address}...');
                bonded = (await FlutterBluetoothSerial.instance
                    .bondDeviceAtAddress(address))!;
                print(
                    'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
              }
              setState(() {
                results[results.indexOf(result)] = BluetoothDiscoveryResult(
                    device: BluetoothDevice(
                      name: device.name ?? '',
                      address: address,
                      type: device.type,
                      bondState: bonded
                          ? BluetoothBondState.bonded
                          : BluetoothBondState.none,
                    ),
                    rssi: result.rssi);
              });
            } catch (ex) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error occured while bonding'),
                    content: Text("${ex.toString()}"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
