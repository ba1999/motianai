import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:motionai/ble_manager.dart';
import 'package:motionai/pages/home_page.dart';
import 'package:motionai/pages/result_page.dart';
import 'package:wakelock/wakelock.dart';

class TrainingPage extends StatefulWidget {
  // Instance of BleManager for managing BLE operations.
  final BleManager bleManager;

  TrainingPage({Key? key, required this.bleManager}) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  // Lists for storing minimum and maximum sensor value notifiers.
  final List notifierMIN = [];
  final List notifierMAX = [];
  // Titles for sensor data display.
  final List _titles = ['AcX', 'AcY', 'AcZ', 'GyX', 'GyY', 'GyZ'];

  @override
  void initState() {
    super.initState();
    // Keep the device awake during training.
    Wakelock.enable();

    // Callback when the BLE device is disconnected. Navigate to ResultPage.
    widget.bleManager.onDeviceDisconnected = () {
      widget.bleManager.isConnected = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(bleManager: widget.bleManager),
          fullscreenDialog: true,
        ),
      );
    };

    // Start monitoring device connection and handle characteristic setting.
    widget.bleManager.monitorDeviceConnection();
    widget.bleManager.onCharacteristicSet = () {
      setState(() {});
    };

    // Listener for loading data state.
    widget.bleManager.loadingData.addListener(() {
      final isLoading = widget.bleManager.loadingData.value;
      if (isLoading) {
        _showLoadingDialog(context);
      } else {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    // Error handling callback.
    widget.bleManager.onError = () {
      _showErrorDialog();
    };

    // Setup minimum and maximum value notifiers for sensor data.
    notifierMIN.add(widget.bleManager.minxNotifier);
    notifierMIN.add(widget.bleManager.minyNotifier);
    notifierMIN.add(widget.bleManager.minzNotifier);
    notifierMIN.add(widget.bleManager.mingxNotifier);
    notifierMIN.add(widget.bleManager.mingyNotifier);
    notifierMIN.add(widget.bleManager.mingzNotifier);
    notifierMAX.add(widget.bleManager.maxxNotifier);
    notifierMAX.add(widget.bleManager.maxyNotifier);
    notifierMAX.add(widget.bleManager.maxzNotifier);
    notifierMAX.add(widget.bleManager.maxgxNotifier);
    notifierMAX.add(widget.bleManager.maxgyNotifier);
    notifierMAX.add(widget.bleManager.maxgzNotifier);
  }

  @override
  void dispose() {
    // Perform cleanup and disable wakelock.
    Wakelock.disable();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    widget.bleManager.onDeviceDisconnected = null;
    widget.bleManager.loadingData.removeListener(() {});
    widget.bleManager.disconnectFromDevice();
    super.dispose();
  }

  // Function to show an error dialog.
  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('BLE-Fehlermeldung'),
          content: Text(
              "Es konnten nicht alle Bluetooth Datenpakete zugestellt werden. Versuchen Sie es erneut"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog when no BLE device is found.
  void _showNoBLEDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('BLE-Fehlermeldung'),
          content: Text("Ladezeit würde überschritten"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a loading dialog.
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Messdaten laden..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        // Appbar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "Klassifikation",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold),
          ),
          // Iconbutton - Finish workout
          actions: [
            IconButton(
                onPressed: () {
                  widget.bleManager.isConnected = false;
                  widget.bleManager.disconnectFromDevice();
                  Future.delayed(Duration(milliseconds: 100));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResultPage(bleManager: widget.bleManager),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                ))
          ],
        ),
        body: widget.bleManager.isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading animation.
            // Main content of the page with real-time data visualization.
            : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              // Card - Result AI
                              child: Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "KI Analyse",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ValueListenableBuilder<String>(
                                            valueListenable: widget
                                                .bleManager.motionNotifierKI,
                                            builder: (context, value, child) {
                                              return Text(value.toString(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontSize: 12));
                                            },
                                          ),
                                          ValueListenableBuilder<int>(
                                            valueListenable: widget.bleManager
                                                .confidenceNotifierKI,
                                            builder: (context, value, child) {
                                              return Text("$value%",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontSize: 12));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              // Card - Result Threshold
                              child: Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Schwellenwert",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      ValueListenableBuilder<String>(
                                        valueListenable: widget
                                            .bleManager.motionNotifierThread,
                                        builder: (context, value, child) {
                                          return Text(value.toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              // Card - Result AI Firebase
                              child: Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "KI Firebase",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ValueListenableBuilder<String>(
                                            valueListenable: widget.bleManager
                                                .motionNotifierFirebase,
                                            builder: (context, value, child) {
                                              return Text(value.toString(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontSize: 12));
                                            },
                                          ),
                                          ValueListenableBuilder<int>(
                                            valueListenable: widget.bleManager
                                                .confidenceNotifierFirebase,
                                            builder: (context, value, child) {
                                              return Text("$value%",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontSize: 12));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        // Listview - Min and Max values
                        Container(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List<Widget>.generate(6, (int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8),
                                child: Material(
                                  elevation: 1.0,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    height: 75,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _titles[index],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("MIN",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer)),
                                                    ValueListenableBuilder<
                                                        double>(
                                                      valueListenable:
                                                          notifierMIN[index],
                                                      builder: (context, value,
                                                          child) {
                                                        return Text("$value",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimaryContainer));
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("MAX",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimaryContainer)),
                                                    ValueListenableBuilder<
                                                        double>(
                                                      valueListenable:
                                                          notifierMAX[index],
                                                      builder: (context, value,
                                                          child) {
                                                        return Text("$value",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimaryContainer));
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Beschleunigung",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "AcX ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    "AcY ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                  Text(
                                    "AcZ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Linechart - Values Acceleration
                        ValueListenableBuilder<List<double>>(
                            valueListenable: widget.bleManager.receivedValuesAX,
                            builder: (context, receivedValues, child) {
                              return Container(
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: LineChart(
                                    LineChartData(
                                      titlesData: FlTitlesData(
                                        leftTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        topTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        rightTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        bottomTitles: SideTitles(),
                                      ),
                                      gridData: FlGridData(
                                        show: false,
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      minX: 0,
                                      maxX: 100,
                                      minY: -4,
                                      maxY: 4,
                                      lineBarsData: [
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesX
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.blue],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesY
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.blueGrey],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesZ
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.black],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Winkelgeschwindigkeit",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "GyX ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    "GyY ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                  Text(
                                    "GyZ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Linechart - Values Gyro
                        ValueListenableBuilder<List<double>>(
                            valueListenable: widget.bleManager.receivedValuesAX,
                            builder: (context, receivedValues, child) {
                              return Container(
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: LineChart(
                                    LineChartData(
                                      titlesData: FlTitlesData(
                                        leftTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        topTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        rightTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        bottomTitles: SideTitles(),
                                      ),
                                      gridData: FlGridData(
                                        show: false,
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      minX: 0,
                                      maxX: 100,
                                      minY: -2000,
                                      maxY: 2000,
                                      lineBarsData: [
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesGX
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.blue],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesGY
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.blueGrey],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                        LineChartBarData(
                                            spots: widget
                                                .bleManager.receivedValuesGZ
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return FlSpot(
                                                e.key.toDouble(),
                                                e.value,
                                              );
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.black],
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 32,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
