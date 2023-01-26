import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import './bluetooth.dart';

class PermStatus {
  PermStatus() {
    acessControlPerm().then((value) => {
          if (value == false)
            {
              exit(0),
            }
        });
  }

  Future<bool> isBluetoothStatus() async {
    final bool control = await Permission.bluetooth.status.isGranted;

    return control;
  }

  Future<bool> isLocationScanStatus() async {
    final bool control = await Permission.location.status.isGranted;

    return control;
  }

  Future<bool> isBluetoothScanStatus() async {
    final bool control = await Permission.bluetoothScan.status.isGranted;

    return control;
  }

  Future<bool> isLocationStatus() async {
    final bool control =
        await Permission.locationWhenInUse.serviceStatus.isEnabled;

    return control;
  }

  Future<bool> acessControlPerm() async {
    isLocationStatus();
    final _bluetoothScan = await isBluetoothScanStatus();
    final _bluetooth = await isBluetoothStatus();
    final _locationScan = await isLocationScanStatus();
    try {
      if (!_bluetooth || !_locationScan || !_bluetoothScan) {
        await Permission.bluetoothScan.request();
        await Permission.bluetooth.request();
        await Permission.location.request();

        if (await isBluetoothScanStatus() &&
            await isBluetoothScanStatus() &&
            await isLocationScanStatus()) {
          return true;
        } else {
          print('gerekli izinler mevcut değil!');
          return false;
        }
      } else {
        print('gerekli izinler mevcut');
        return true;
      }
    } catch (e) {
      throw (e);
    }
  }
}
