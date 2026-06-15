// lib/screens/debug_screen.dart
import 'package:flutter/material.dart';
import '../utils/firebase_test.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _testOutput = '';
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _runBasicTest,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _runFullTest,
                    icon: const Icon(Icons.assessment),
                    label: const Text('Full Test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _clearOutput,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Output'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testOutput,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runBasicTest() async {
    setState(() {
      _isTesting = true;
      _testOutput = 'Starting basic Firebase test...\n\n';
    });

    // Capture print output
    List<String> output = [];
    
    void capturePrint(String message) {
      output.add(message);
      setState(() {
        _testOutput = output.join('\n');
      });
    }

    // Override print temporarily
    var originalPrint = print;
    print = capturePrint;

    try {
      await FirebaseTest.testAllConnections();
    } catch (e) {
      capturePrint('❌ Test error: $e');
    } finally {
      print = originalPrint;
      setState(() {
        _isTesting = false;
        _testOutput += '\n\nTest completed!';
      });
    }
  }

  void _runFullTest() async {
    setState(() {
      _isTesting = true;
      _testOutput = 'Starting complete Firebase test...\n\n';
    });

    List<String> output = [];
    
    void capturePrint(String message) {
      output.add(message);
      setState(() {
        _testOutput = output.join('\n');
      });
    }

    var originalPrint = print;
    print = capturePrint;

    try {
      await FirebaseTest.runCompleteTest();
    } catch (e) {
      capturePrint('❌ Test error: $e');
    } finally {
      print = originalPrint;
      setState(() {
        _isTesting = false;
        _testOutput += '\n\nComplete test finished!';
      });
    }
  }

  void _clearOutput() {
    setState(() {
      _testOutput = '';
    });
  }
}