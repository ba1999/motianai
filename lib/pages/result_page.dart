import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:motionai/pages/home_page.dart';

import '../ble_manager.dart';

class ResultPage extends StatefulWidget {
  // Instance of BleManager for managing BLE operations.
  final BleManager bleManager;
  ResultPage({Key? key, required this.bleManager}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      // Appbar
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "Ergebnis",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold),
          ),
          // Iconbutton - Information
          actions: [
            IconButton(
              icon: Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                // Show a dialog with information about different motion types.
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Information"),
                      content: Text(
                          "Sprung V = Vertikaler Sprung\n\nSprung H = Horizontaler Sprung\n\nLaufen V = Laufen Vorwärts\n\nLaufen A = Laufen auf der Stelle"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      // Card - Information for Threshold
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Schwellenwert",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              SizedBox(height: 8),
                              // Piechart Threshold
                              Container(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.blue[300],
                                        value: widget
                                            .bleManager.motionThreadcounter0
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionThreadcounter0
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[500],
                                        value: widget
                                            .bleManager.motionThreadcounter1
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionThreadcounter1
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[700],
                                        value: widget
                                            .bleManager.motionThreadcounter2
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionThreadcounter2
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[900],
                                        value: widget
                                            .bleManager.motionThreadcounter3
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionThreadcounter3
                                            .toString(),
                                        radius: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sprung V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[300])),
                                  Text("Sprung H",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[500])),
                                  Text("Laufen V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700])),
                                  Text("Laufen A",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      // Card - Information for AI
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "KI Analyse",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              SizedBox(height: 16),
                              // Piechart AI
                              Container(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.blue[300],
                                        value: widget
                                            .bleManager.motionKIcounter0
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionKIcounter0
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[500],
                                        value: widget
                                            .bleManager.motionKIcounter1
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionKIcounter1
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[700],
                                        value: widget
                                            .bleManager.motionKIcounter2
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionKIcounter2
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[900],
                                        value: widget
                                            .bleManager.motionKIcounter3
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionKIcounter3
                                            .toString(),
                                        radius: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sprung V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[300])),
                                  Text("Sprung H",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[500])),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Laufen V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700])),
                                  Text("Laufen A",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900])),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Genauigkeit:",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer)),
                                  Text("${widget.bleManager.confidenceKI}%",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      // Card - Information for AI Firebase
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "KI Firebase",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              SizedBox(height: 16),
                              // Piechart AI Firebase
                              Container(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.blue[300],
                                        value: widget
                                            .bleManager.motionFirecounter0
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionFirecounter0
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[500],
                                        value: widget
                                            .bleManager.motionFirecounter1
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionFirecounter1
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[700],
                                        value: widget
                                            .bleManager.motionFirecounter2
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionFirecounter2
                                            .toString(),
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue[900],
                                        value: widget
                                            .bleManager.motionFirecounter3
                                            .toDouble(),
                                        title: widget
                                            .bleManager.motionFirecounter3
                                            .toString(),
                                        radius: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sprung V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[300])),
                                  Text("Sprung H",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[500])),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Laufen V",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700])),
                                  Text("Laufen A",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900])),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Genauigkeit:",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer)),
                                  Text(
                                      "${widget.bleManager.confidenceFirebase}%",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                // Button - Change page to home
                FilledButton(
                    onPressed: () {
                      // Navigate to the HomePage when the button is pressed.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Text("Weiter"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
