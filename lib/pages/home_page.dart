import 'package:flutter/material.dart';
import 'package:motionai/ble_manager.dart';
import 'package:motionai/pages/training_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance of BleManager for managing BLE operations.
  BleManager bleManager = BleManager();

  @override
  void initState() {
    super.initState();
    bleManager.loadAI(); // Load the AI model on initialization.

    // Set up a callback for when the BLE device is connected.
    bleManager.onDeviceConnected = () {
      if (bleManager.isConnected) {
        // Navigate to the TrainingPage when a device is successfully connected.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingPage(bleManager: bleManager),
            fullscreenDialog: true,
          ),
        );
      }
    };

    // Set up a callback for when no BLE device is found.
    bleManager.onNoDeviceFound = () {
      // Show an alert dialog if no BLE device is found.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Kein Gerät gefunden"),
            content: Text(
                "Es wurde kein BLE-Gerät mit dem Namen 'MotionAI' gefunden.\n\nSchallten Sie die Trainingsweste an und versuchen Sie es erneut."),
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
    };
  }

  // Function to show a loading dialog while connecting to a device.
  void showLoadingDialog(BuildContext context) {
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
                Text("Verbinden..."),
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
          "MotionAI",
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold),
        ),
      ),
      // Body
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Image - Home
              Image.asset(
                'assets/home.png',
                height: 250,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text - Wellcome to MotionAI
                  Text(
                    "Wilkommen bei MotionAI",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  // Text - Information
                  Text(
                    "MotionAI ist eine Künstliche Intelligenz die Ihre Bewegung anhand von Wearables Tracken kann! Um Fortzufahren Verbinden Sie die App mit Ihrem Wearable.",
                  ),
                ],
              ),
              // Button - Search for BLE devices
              FilledButton(
                  onPressed: () {
                    if (!bleManager.isSearching) {
                      bleManager
                          .scanForDevices(); // Start scanning for devices on button press.
                      bleManager.isSearching = true;
                    }
                  },
                  child: Text("Verbinden"))
            ],
          ),
        ),
      ),
    );
  }
}
