import 'dart:convert';
import 'package:crclib/catalog.dart';
import 'package:flutter/material.dart';
import 'package:furnita_ios/utils/bluetooth_util.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:furnita_ios/utils/iv_password_provider.dart';
import 'package:provider/provider.dart';
import 'package:furnita_ios/utils/randomize.dart';
import 'package:furnita_ios/utils/encryption.dart';
import 'dart:typed_data';

class ReusableCard extends StatefulWidget {
  dynamic bleName, bleAddress, bleRssi, bleSerialNumber;

  BleUtil bleUtil = BleUtil();

  ReusableCard(
      {this.bleName,
      required this.bleAddress,
      this.bleRssi,
      this.bleSerialNumber});

  @override
  State<ReusableCard> createState() => _ReusableCardState();
}

class _ReusableCardState extends State<ReusableCard> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BleUtil bleUtil = BleUtil();
  // final device = BluetoothDevice(remoteId: DeviceIdentifier(widget.bleAddress));
  dynamic device;

  int ctr = 0;
  IvJump ivJump = IvJump();
  bool? connectionStatus, isConnected;
  bool isLoading = false;
  dynamic statusColor = (Colors.black);
  String label = 'Connect';
  late String epochTime;
  Widget ButtonChild = Text(
    'Connect',
    style: TextStyle(
        color: Color(0xFFFFFFFF).withOpacity(0.5), fontFamily: 'Ubuntu'),
  );

  String giveEpochTime() {
    String timeGMT = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
        .round()
        .toRadixString(16)
        .toUpperCase();
    return timeGMT;
  }

  @override
  Widget build(BuildContext context) {
    String unlockCmd = Provider.of<IvPasswordProvider>(context).unlockCmd;
    String updatedIv = Provider.of<IvPasswordProvider>(context).newIV;
    String updatedPassword = Provider.of<IvPasswordProvider>(context).newPass;

    return GestureDetector(
      child: Card(
        elevation: 2,
        color: Color(0XFFF2F2F7),
        margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
        child: ListTile(
          leading: Icon(
            Icons.bluetooth,
            size: 30,
            color: Colors.black,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.bleName,
                  style: TextStyle(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                widget.bleRssi,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.bleSerialNumber,
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Color(0xFFA0A0B0),
                      fontFamily: 'Ubuntu'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                ),
                onPressed: () async {
                  ButtonChild = CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFFFFFFF),
                  );
                  print(
                      'Trying to establish connection with : ${widget.bleAddress}');
                  connectionStatus = await bleUtil
                      .connectToDevice(widget.bleAddress.toString());

                  // bleUtil.connectToStoredDevice();

                  epochTime = giveEpochTime();
                  print('Epoch Time: $epochTime');
                  print('----------------------------------');
                  unlockCmd += epochTime;
                  print('Unlock Command with epcoh: $unlockCmd');
                  print('----------------------------------');

                  List<int> unlockCmdHex = [];
                  for (int i = 0; i < unlockCmd.length; i += 2) {
                    int value =
                        int.parse(unlockCmd.substring(i, i + 2), radix: 16);
                    String hexString =
                        value.toRadixString(16).padLeft(2, '0').toUpperCase();
                    unlockCmdHex.add(int.parse(hexString, radix: 16));
                  }

                  String crc16 = Crc16Xmodem()
                      .convert(Uint8List.fromList(unlockCmdHex))
                      .toRadixString(16)
                      .toUpperCase();

                  if (crc16.length < 4) {
                    crc16 = crc16.padLeft(4, '0');
                  }
                  print('CRC16: $crc16');
                  print('----------------------------------');

                  unlockCmd += crc16;
                  unlockCmd += "23";
                  print('Unlock Command with CRC: $unlockCmd');
                  print('----------------------------------');

                  Uint8List bytes = Uint8List.fromList([
                    for (int i = 0; i < unlockCmd.length; i += 2)
                      int.parse(unlockCmd.substring(i, i + 2), radix: 16)
                  ]);

                  print('Bytes: $bytes');
                  print('----------------------------------');

                  Uint8List encryptedBytes = Encryption().encryptData(
                      bytes,
                      updatedPassword,
                      Uint8List.fromList(utf8.encode(updatedIv)));
                  print('Encrypted byts are: $encryptedBytes');

                  String hexToBase64(String hex) {
                    // Convert hex string to bytes
                    Uint8List bytes = Uint8List.fromList([
                      for (int i = 0; i < hex.length; i += 2)
                        int.parse(hex.substring(i, i + 2), radix: 16)
                    ]);

                    // Encode bytes in Base64
                    return base64Encode(bytes);
                  }

                  String encoded = hexToBase64(encryptedBytes
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join());

                  print("Base 64 value of unlock cmd is - $encoded");
                  print('------------------------------------');

                  device = BluetoothDevice(
                      remoteId: DeviceIdentifier(widget.bleAddress));

                  await bleUtil.sendData(device, encoded);
                  await Future.delayed(Duration(seconds: 4));
                  await bleUtil.disconnectFromDevice(widget.bleAddress);

                  ctr++;
                  setState(
                    () {
                      if (connectionStatus == true) {
                        statusColor = Colors.green;
                        isConnected = true;
                        label = 'Disconnect';
                        ButtonChild = Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontFamily: 'Ubuntu',
                          ),
                        );
                      } else {
                        statusColor = Colors.red;
                        isConnected = false;
                      }

                      if (connectionStatus == true && ctr == 1) {
                        print('Shifting slide');
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return ConnectedScreen(
                        //         bleName: widget.bleName,
                        //         bleAddress: widget.bleAddress,
                        //       );
                        //     },
                        //   ),
                        // );
                      }

                      if (isConnected == true && ctr > 1) {
                        print('Trying to disconnect');
                        bleUtil
                            .disconnectFromDevice(widget.bleAddress.toString());
                        statusColor = Colors.black;
                        isConnected = false;
                        label = 'Connect';
                        ButtonChild = Text(
                          label,
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.5),
                            fontFamily: 'Ubuntu',
                          ),
                        );
                        ctr = 0;
                      }
                    },
                  );
                },
                child: ButtonChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
