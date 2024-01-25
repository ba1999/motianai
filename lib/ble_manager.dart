import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class BleManager {
  bool isConnected = false;
  bool isLoading = true;
  bool isSearching = false;
  Function? onCharacteristicSet;
  Function? onDeviceConnected;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice _selectedDevice;
  BluetoothCharacteristic? _customCharacteristic;
  int counter = 0;
  List<double> receivedValuesX = [];
  List<double> receivedValuesY = [];
  List<double> receivedValuesZ = [];
  List<double> receivedValuesGX = [];
  List<double> receivedValuesGY = [];
  List<double> receivedValuesGZ = [];
  List<double> receivedValues = [];
  late Interpreter interpreter;

  final ValueNotifier<bool> loadingData = ValueNotifier<bool>(false);
  final ValueNotifier<String> motionNotifierKI = ValueNotifier<String>("-");
  final ValueNotifier<String> motionNotifierThread = ValueNotifier<String>("-");
  final ValueNotifier<String> motionNotifierFirebase =
      ValueNotifier<String>("-");
  final ValueNotifier<int> confidenceNotifierKI = ValueNotifier<int>(0);
  final ValueNotifier<int> confidenceNotifierFirebase = ValueNotifier<int>(0);
  final ValueNotifier<double> minxNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> minyNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> minzNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxxNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxyNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxzNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> mingxNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> mingyNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> mingzNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxgxNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxgyNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> maxgzNotifier = ValueNotifier<double>(0.0);

  int motionKIcounter0 = 0;
  int motionKIcounter1 = 0;
  int motionKIcounter2 = 0;
  int motionKIcounter3 = 0;
  int motionThreadcounter0 = 0;
  int motionThreadcounter1 = 0;
  int motionThreadcounter2 = 0;
  int motionThreadcounter3 = 0;
  int motionFirecounter0 = 0;
  int motionFirecounter1 = 0;
  int motionFirecounter2 = 0;
  int motionFirecounter3 = 0;
  int confidenceKI = 0;
  int confidenceFirebase = 0;
  int confidenceKISum = 0;
  int confidenceFirebaseSum = 0;
  int confidenceKICounter = 0;
  int confidenceFirebaseCounter = 0;

  int packetCountX = 0;
  int packetCountY = 0;
  int packetCountZ = 0;
  int packetCountGX = 0;
  int packetCountGY = 0;
  int packetCountGZ = 0;
  int end = 0;

  final List<double> means = [0.9786, 0.0745, 0.3037, -4.1858, 2.4569, 0.6723];
  final List<double> stdDevs = [
    0.67618344,
    0.43351903,
    0.30864431,
    56.92824807,
    24.40493039,
    19.50881415
  ];

  Function()? onError;

  Function? onDeviceDisconnected; // Callback für Gerätetrennung

  Future<void> monitorDeviceConnection() async {
    _selectedDevice.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        isConnected = false;
        onDeviceDisconnected
            ?.call(); // Ruft den Callback auf, wenn das Gerät getrennt wird
      }
    });
  }

  List<double> scaleData(List<double> rawData) {
    List<double> scaledData = List.generate(rawData.length, (index) {
      int featureIndex = index % 6;
      return (rawData[index] - means[featureIndex]) / stdDevs[featureIndex];
    });
    return scaledData;
  }

  ValueNotifier<List<double>> receivedValuesAX = ValueNotifier([]);
  ValueNotifier<List<double>> receivedValuesAY = ValueNotifier([]);
  ValueNotifier<List<double>> receivedValuesAYZ = ValueNotifier([]);

  final Guid customServiceUuid = Guid("0000FFE0-0000-1000-8000-00805F9B34FB");
  final Guid customCharacteristicUuid =
      Guid("0000FFE1-0000-1000-8000-00805F9B34FB");

  StreamSubscription<List<int>>? _notificationSubscription;

  Timer? _scanTimer;
  bool _deviceFound = false;
  Function? onNoDeviceFound; // Callback for no device found

  void scanForDevices() {
    _deviceFound = false;
    flutterBlue.startScan(timeout: Duration(seconds: 2));

    // Start a timer for 3 seconds
    _scanTimer = Timer(Duration(seconds: 2), () {
      if (!_deviceFound) {
        flutterBlue.stopScan();
        isSearching = false;
        onNoDeviceFound?.call(); // Trigger the callback if no device found
      }
    });

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "MotionAI") {
          _deviceFound = true;
          _scanTimer?.cancel(); // Cancel the timer
          flutterBlue.stopScan();
          isSearching = false;
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  set customCharacteristic(BluetoothCharacteristic? value) {
    _customCharacteristic = value;
    if (_customCharacteristic != null) {
      isLoading = false;
      onCharacteristicSet?.call();
      setCharacteristicNotifications();
    }
  }

  Future<void> loadAI() async {
    FirebaseCustomModel model = await FirebaseModelDownloader.instance.getModel(
        "motionai",
        FirebaseModelDownloadType.localModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: false,
          androidChargingRequired: false,
          androidWifiRequired: false,
          androidDeviceIdleRequired: false,
        ));
    print("Modell geladen: ${model.file.path}");
    interpreter = Interpreter.fromFile(model.file);
    //interpreter = await Interpreter.fromAsset('assets/models/ki_modell.tflite');
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _selectedDevice = device;
      await _selectedDevice.connect().then((value) async {
        receivedValuesX =
            List<double>.generate(100, (index) => 0.0); // 100 zeros
        receivedValuesY =
            List<double>.generate(100, (index) => -0.2); // 100 -1s
        receivedValuesZ = List<double>.generate(100, (index) => 0.2);
        receivedValuesGX =
            List<double>.generate(100, (index) => 0.0); // 100 zeros
        receivedValuesGY =
            List<double>.generate(100, (index) => -200.0); // 100 -1s
        receivedValuesGZ = List<double>.generate(100, (index) => 200);
        // Finde die benutzerdefinierte Charakteristik im Service
        isConnected = true;
        onDeviceConnected?.call();
        // loadAI();

        List<BluetoothService> services = await device.discoverServices();
        for (var service in services) {
          if (service.uuid == customServiceUuid) {
            var characteristics = service.characteristics;
            for (var char in characteristics) {
              if (char.uuid == customCharacteristicUuid) {
                customCharacteristic = char;
                print('Custom characteristic found and initialized');
              }
            }
          }
        }
      });
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> disconnectFromDevice() async {
    if (_selectedDevice != null) {
      await _selectedDevice.disconnect().then((value) async {
        _notificationSubscription?.cancel();
        _notificationSubscription = null;
        _customCharacteristic = null;
        isLoading = true;

        // Variablen zurücksetzen
        counter = 0;
        receivedValuesX.clear();
        receivedValuesY.clear();
        receivedValuesZ.clear();
        motionNotifierKI.value = "-";
        motionNotifierThread.value = "-";
        motionNotifierFirebase.value = "-";
        packetCountX = 0;
        packetCountY = 0;
        packetCountZ = 0;
        end = 0;
      });
    }
  }

  Future<void> sendJsonData(Map<String, dynamic> jsonData) async {
    try {
      if (_customCharacteristic != null) {
        String jsonString = jsonEncode(jsonData);
        List<int> jsonDataBytes = utf8.encode(jsonString);
        await _customCharacteristic!
            .write(jsonDataBytes, withoutResponse: false);
      } else {
        print('Custom characteristic not available');
      }
    } catch (e) {
      print('Error sending JSON data: $e');
    }
  }

  void updateReceivedValuesX(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesX.addAll(newValues);
  }

  void updateReceivedValuesY(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesY.addAll(newValues);
  }

  void updateReceivedValuesZ(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesZ.addAll(newValues);
  }

  void updateReceivedValuesGX(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesGX.addAll(newValues);
  }

  void updateReceivedValuesGY(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesGY.addAll(newValues);
  }

  void updateReceivedValuesGZ(List<double> newValues) {
    // Fügen Sie die neuen Werte hinzu
    receivedValuesGZ.addAll(newValues);
    receivedValuesAX.value = List.from(receivedValuesGZ);
  }

  Future<void> setCharacteristicNotifications() async {
    try {
      if (_selectedDevice != null && _customCharacteristic != null) {
        await _customCharacteristic!.setNotifyValue(true);
        await _selectedDevice.requestMtu(512);

        _notificationSubscription = _customCharacteristic!.value.listen((data) {
          String receivedData = String.fromCharCodes(data);
          print('Received data: $receivedData');

          print(counter.toString());
          try {
            Map<String, dynamic> jsonData = jsonDecode(receivedData);

            // Extracting the data
            /*  double acx = sensorData['ACX'];
          double acy = sensorData['ACY'];
          double acz = sensorData['ACZ'];
          double gyx = sensorData['GYX'];
          double gyy = sensorData['GYY'];
          double gyz = sensorData['GYZ'];*/

            if (jsonData.containsKey('KI')) {
              loadingData.value = true;
              int ki = jsonData['KI'];
              int schwelle = jsonData['THREAD'];
              int confidence = (jsonData['CONF'] * 100).toInt();

              if (confidence > 50) {
                switch (ki) {
                  case 0:
                    motionKIcounter0++;
                    motionNotifierKI.value = "Sprung V";
                    break;
                  case 1:
                    motionKIcounter1++;
                    motionNotifierKI.value = "Spruch H";
                    break;
                  case 2:
                    motionKIcounter2++;
                    motionNotifierKI.value = "Laufen V";
                    break;
                  case 3:
                    motionKIcounter3++;
                    motionNotifierKI.value = "Laufen A";
                    break;
                  default:
                    motionNotifierKI.value =
                        "-"; // Default case if ki is neither 0 nor 1
                    break;
                }
                confidenceNotifierKI.value = confidence;
                confidenceKICounter++;
                confidenceKISum = confidenceKISum + confidenceNotifierKI.value;
                confidenceKI = (confidenceKISum / confidenceKICounter).toInt();
              } else {
                motionNotifierKI.value = "-";
                confidenceNotifierKI.value = 100 - confidence;
              }

              switch (schwelle) {
                case 0:
                  motionThreadcounter0++;
                  motionNotifierThread.value = "Sprung V";
                  break;
                case 1:
                  motionThreadcounter1++;
                  motionNotifierThread.value = "Spruch H";
                  break;
                case 2:
                  motionThreadcounter2++;
                  motionNotifierThread.value = "Laufen V";
                  break;
                case 3:
                  motionThreadcounter3++;
                  motionNotifierThread.value = "Laufen A";
                  break;
                default:
                  motionNotifierThread.value =
                      "-"; // Default case if ki is neither 0 nor 1
                  break;
              }

              // motionNotifier1.value = ki;
              // motionNotifier2.value = schwelle;

              receivedValuesX.clear();
              receivedValuesY.clear();
              receivedValuesZ.clear();
              receivedValuesGX.clear();
              receivedValuesGY.clear();
              receivedValuesGZ.clear();

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }

            if (jsonData.containsKey('MINX')) {
              minxNotifier.value =
                  ((jsonData['MINX']).toDouble() * 100).round() / 100;
              minyNotifier.value =
                  ((jsonData['MINY']).toDouble() * 100).round() / 100;
              minzNotifier.value =
                  ((jsonData['MINZ']).toDouble() * 100).round() / 100;
              maxxNotifier.value =
                  ((jsonData['MAXX']).toDouble() * 100).round() / 100;
              maxyNotifier.value =
                  ((jsonData['MAXY']).toDouble() * 100).round() / 100;
              maxzNotifier.value =
                  ((jsonData['MAXZ']).toDouble() * 100).round() / 100;
            }

            if (jsonData.containsKey('MINGX')) {
              mingxNotifier.value =
                  ((jsonData['MINGX']).toDouble() * 100).round() / 100;
              mingyNotifier.value =
                  ((jsonData['MINGY']).toDouble() * 100).round() / 100;
              mingzNotifier.value =
                  ((jsonData['MINGZ']).toDouble() * 100).round() / 100;
              maxgxNotifier.value =
                  ((jsonData['MAXGX']).toDouble() * 100).round() / 100;
              maxgyNotifier.value =
                  ((jsonData['MAXGY']).toDouble() * 100).round() / 100;
              maxgzNotifier.value =
                  ((jsonData['MAXGZ']).toDouble() * 100).round() / 100;
            }

            if (jsonData.containsKey('AX')) {
              packetCountX++;
              if (end == 1) {
                receivedValuesX.clear();
                receivedValuesY.clear();
                receivedValuesZ.clear();
                receivedValuesGX.clear();
                receivedValuesGY.clear();
                receivedValuesGZ.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['AX'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesX(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('AY')) {
              packetCountY++;
              if (end == 1) {
                receivedValuesY.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['AY'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesY(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('AZ')) {
              packetCountZ++;
              if (end == 1) {
                receivedValuesZ.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['AZ'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesZ(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('GX')) {
              packetCountGX++;
              if (end == 1) {
                receivedValuesGX.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['GX'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesGX(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('GY')) {
              packetCountGY++;
              if (end == 1) {
                receivedValuesGY.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['GY'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesGY(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('GZ')) {
              packetCountGZ++;
              if (end == 1) {
                receivedValuesGZ.clear();
                end = 0;
              }

              List<dynamic> values = jsonData['GZ'];
              //receivedValues.addAll(values.cast<double>());
              updateReceivedValuesGZ(values.cast<double>());

              // Sie könnten hier eine Benachrichtigung senden, um das Diagramm zu aktualisieren
            }
            if (jsonData.containsKey('END')) {
              loadingData.value = false;
              end = jsonData['END'];
              receivedValues.clear();
              //receivedValues = List<double>.filled(6 * 100, 0.0);
              try {
                for (int i = 0; i < receivedValuesX.length; i++) {
                  /*  receivedValues[6 * i + 0] = receivedValuesX[i];
                  receivedValues[6 * i + 1] = receivedValuesY[i];
                  receivedValues[6 * i + 2] = receivedValuesZ[i];
                  receivedValues[6 * i + 3] = receivedValuesGX[i];
                  receivedValues[6 * i + 4] = receivedValuesGY[i];
                  receivedValues[6 * i + 5] = receivedValuesGZ[i];*/

                  receivedValues.add(receivedValuesX[i]);
                  receivedValues.add(receivedValuesY[i]);
                  receivedValues.add(receivedValuesZ[i]);
                  receivedValues.add(receivedValuesGX[i]);
                  receivedValues.add(receivedValuesGY[i]);
                  receivedValues.add(receivedValuesGZ[i]);
                }
                List<double> scaledValues = scaleData(receivedValues);
                // Konvertiere die Daten in das erforderliche Format
                // Beispiel: Du erwartest ein 1D-Float-Array als Eingabe
                List<double> inputValues = receivedValues;
                Float32List inputBuffer = Float32List.fromList(scaledValues);

                //interpreter.allocateTensors();

                // Bereite den Ausgabepuffer vor
                Float32List outputBuffer = Float32List(4);

                // Führe das Modell aus
                print("Eingabegröße: ${inputBuffer.length}");
                if (inputBuffer.length == 600) {
                  interpreter.run(inputBuffer.buffer.asUint8List(),
                      outputBuffer.buffer.asUint8List());
                  final highestProb = outputBuffer.reduce(max);
                  final predictedIndex = outputBuffer.indexOf(highestProb);

                  if ((highestProb * 100).toInt() > 49) {
                    switch (predictedIndex) {
                      case 0:
                        motionFirecounter0++;
                        motionNotifierFirebase.value = "Sprung V";
                        break;
                      case 1:
                        motionFirecounter1++;
                        motionNotifierFirebase.value = "Spruch H";
                        break;
                      case 2:
                        motionFirecounter2++;
                        motionNotifierFirebase.value = "Laufen V";
                        break;
                      case 3:
                        motionFirecounter3++;
                        motionNotifierFirebase.value = "Laufen A";
                        break;
                      default:
                        motionNotifierFirebase.value =
                            "-"; // Default case if ki is neither 0 nor 1
                        break;
                    }
                    confidenceNotifierFirebase.value =
                        (highestProb * 100).toInt();
                    confidenceFirebaseCounter++;
                    confidenceFirebaseSum = confidenceFirebaseSum +
                        confidenceNotifierFirebase.value;
                    confidenceFirebase =
                        (confidenceFirebaseSum / confidenceFirebaseCounter)
                            .toInt();
                  } else {
                    motionNotifierFirebase.value = "-";
                    confidenceNotifierFirebase.value =
                        100 - (highestProb * 100).toInt();
                  }
                  print(
                      "Vorhergesagter Index: $predictedIndex mit Wahrscheinlichkeit: $highestProb");
                  // Verarbeite die Ausgabe
                } else {
                  print(
                      "Ungültige Eingabegröße: erwartet 600, erhalten ${inputBuffer.length}");
                }
                // Finde die Vorhersage mit der höchsten Wahrscheinlichkeit

                print(
                    "Vorhersage: ${outputBuffer[0]} ,  ${outputBuffer[1]} ,  ${outputBuffer[2]} ,  ${outputBuffer[3]}");
                //   print("Vorhersage: ${outputBuffer[1]}");
                //  print("Vorhersage: ${outputBuffer[2]}");
                //  print("Vorhersage: ${outputBuffer[3]}");
              } catch (e) {
                String errorValue = "-";
                int errorConfidence = 0;
                motionNotifierFirebase.value = errorValue;
                confidenceNotifierFirebase.value = errorConfidence;
                onError?.call();
                print("Fehler beim Verarbeiten der Daten: $e");
              }
            }
          } catch (e) {
            print("JSON Fehler");
          }
        });
        print('Notifications enabled');
      } else {
        print('Device or characteristic not available');
      }
    } catch (e) {
      print('Error setting notifications: $e');
    }
  }
}
