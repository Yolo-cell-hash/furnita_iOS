import 'package:flutter/scheduler.dart';
import 'package:furnita_ios/utils/iv_password_provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:furnita_ios/widgets/reusable_cards.dart';
import 'package:furnita_ios/utils/change_icon.dart';
import 'package:furnita_ios/utils/bluetooth_util.dart';
import 'package:furnita_ios/utils/randomize.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BleUtil bleUtil = BleUtil();
  SetIconForButton setIconForButton = SetIconForButton();
  bool state = true;
  String mountedLock = "00000202";
  IvJump ivJump = IvJump();
  late String UID;
  late String UID_first, UID_second, UID_third, UID_fourth;
  dynamic UID_first_int, UID_second_int, UID_third_int, UID_fourth_int;

  String unlockCmd =
      "2A431B50653431313033353132333435363740533030303030303131353131313830343230323531323030303031383034323032363131353930303131313131313136344146";
  bool isClicked = false;
  int? clickedIndex;
  double verticalSpacefromBottom = 60.0;

  void updateProvider(String newIV, String newPass, String unlockCmd) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<IvPasswordProvider>(context, listen: false).updateIV(newIV);
      Provider.of<IvPasswordProvider>(context, listen: false)
          .updatePass(newPass);
      Provider.of<IvPasswordProvider>(context, listen: false)
          .updateUnlockCmd(unlockCmd);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(verticalSpacefromBottom),
            child: AppBar(
              backgroundColor: Color(0xFF000000),
              centerTitle: true,
              title: const Opacity(
                opacity: 0.5,
                child: const Text(
                  'Godrej Locks',
                  style:
                      TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'Ubuntu'),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              bleUtil.getPermissions();
              bleUtil.findBleState();
              bleUtil.startScan();
              setState(() {
                setIconForButton.changeLogo(state);
                state = false;
              });
            },
            backgroundColor: Color(0XFF000000),
            icon: setIconForButton.changeLogo(state),
            label: setIconForButton.changeText(state),
          ),
          body: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  StreamBuilder<List<ScanResult>>(
                    stream: bleUtil.scanedDevices(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, 0, 0, verticalSpacefromBottom),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Opacity(
                                    opacity: 0.20,
                                    child: Icon(
                                      Icons.bluetooth_disabled,
                                      size: 250,
                                      color: Colors.black,
                                    )),
                              ),
                              Center(
                                child: Opacity(
                                    opacity: 0.20,
                                    child: Text(
                                      'Scan to find Devices',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    )),
                              )
                            ],
                          ),
                        );
                      } else {
                        List<ScanResult> results = snapshot.data!;

                        return Container(
                          height: MediaQuery.of(context).size.height *
                              1, // Adjust the height as needed

                          child: ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              ScanResult result = results[index];

                              if (result.advertisementData.advName ==
                                  mountedLock) {
                                FlutterBluePlus.stopScan();
                                print('Scanning stopped');
                              }

                              String manufData = result
                                  .advertisementData.manufacturerData.values
                                  .expand((list) => list)
                                  .map((value) =>
                                      value.toRadixString(16).padLeft(2, '0'))
                                  .join();

                              print('Manuf Data: $manufData');

                              // String UID_str = (manufData.substring(28, 37));
                              // print("UID as an STR is - $UID_str");

                              UID_first = manufData.substring(24, 26);
                              UID_first_int = int.parse(
                                  UID_first.padLeft(2, '0'),
                                  radix: 16);
                              if (UID_first_int < 10) {
                                UID_first_int = '0$UID_first_int';
                              }
                              print('UID first int is - $UID_first_int');

                              UID_second = manufData.substring(26, 28);
                              UID_second_int = int.parse(
                                  UID_second.padLeft(2, '0'),
                                  radix: 16);
                              if (UID_second_int < 10) {
                                UID_second_int = '0$UID_second_int';
                              }
                              print('UID second int is - $UID_second_int');

                              UID_third = manufData.substring(28, 30);
                              UID_third_int = int.parse(
                                  UID_third.padLeft(2, '0'),
                                  radix: 16);
                              if (UID_third_int < 10) {
                                UID_third_int = '0$UID_third_int';
                              }
                              print('UID third int is - $UID_third_int');

                              UID_fourth = manufData.substring(30, 32);
                              UID_fourth_int = int.parse(
                                  UID_fourth.padLeft(2, '0'),
                                  radix: 16);
                              if (UID_fourth_int < 10) {
                                UID_fourth_int = '0$UID_fourth_int';
                              }

                              print('UID fourth int is - $UID_fourth_int');

                              UID = UID_first_int.toString();
                              UID += UID_second_int.toString();
                              UID += UID_third_int.toString();
                              UID += UID_fourth_int.toString();

                              print('Generated UID is - $UID');
                              print("---------------------------------");

                              String newIV =
                                  ivJump.replaceIVWithUID(ivJump.iv, UID);
                              String newPass = ivJump.replacePasswordWithUID(
                                  ivJump.password, UID);

                              print("Old IV is - ${ivJump.iv}");
                              print('New IV is - $newIV');
                              print("---------------------------------");
                              print("Old Password is - ${ivJump.password}");
                              print('New Password is - $newPass');
                              print("---------------------------------");

                              updateProvider(newIV, newPass, unlockCmd);

                              print('Unlock Command is - $unlockCmd');
                              print("---------------------------------");

                              String asciiString = String.fromCharCodes(
                                  List.generate(
                                      manufData.length ~/ 2,
                                      (i) => int.parse(
                                          manufData.substring(i * 2, i * 2 + 2),
                                          radix: 16)));
                              if (asciiString.isEmpty ||
                                  asciiString == null ||
                                  asciiString.length > 30) {
                                asciiString = ' - ';
                              }

                              return ReusableCard(
                                bleAddress: result.device.remoteId.toString(),
                                bleSerialNumber: asciiString.toString(),
                                bleName: result.advertisementData.advName
                                        .toString() ??
                                    'Unknown',
                                bleRssi: result.rssi.toString(),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
