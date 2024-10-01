import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart'; // Make sure this import is correct
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class SpirometryScreen extends StatefulWidget {
  const SpirometryScreen({super.key});

  @override
  _SpirometryScreenState createState() => _SpirometryScreenState();
}

class _SpirometryScreenState extends State<SpirometryScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  String _loggedData = "";
  bool _isConnected = false;
  BluetoothDevice? _selectedDevice;
  List<FlSpot> _chartData = []; // List to hold FlSpot data for the graph
  int _chartDataLength = 0; // To track data length for X-axis

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;

  void _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.locationWhenInUse.request();
  }

  void _connectToDevice() async {
    if (_selectedDevice != null) {
      await _bluetoothService.connectToDevice(_selectedDevice!.address);
      setState(() {
        _isConnected = true;
      });
    }
  }

  void _startLogging() {
    if (_isConnected) {
      _bluetoothService.startLogging((data) {
        setState(() {
          _loggedData += data;

          // Convert incoming data (string) to a double and add it as a new FlSpot to _chartData
          double? value = double.tryParse(data);  // Ensure valid parsing
          if (value != null) {
            _chartData.add(FlSpot(_chartDataLength.toDouble(), value)); // Add parsed value as FlSpot
            _chartDataLength++; // Increment X-axis value
          }
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connect to the device first!")),
      );
    }
  }

  void _stopLogging() {
    _bluetoothService.stopLogging();
  }

  void _discoverDevices() async {
    await _bluetoothService.discoverDevices();
    setState(() {}); // Update the state after discovering devices
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _discoverDevices();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.grey, // Customize the grid line color
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey, // Customize the grid line color
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: _chartDataLength.toDouble() - 1, // Use _chartDataLength for X-axis
      minY: 0, // Adjust the minimum Y value as needed
      maxY: 100, // Adjust the maximum Y value as needed
      lineBarsData: [
        LineChartBarData(
          spots: _chartData, // Use _chartData directly
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: _chartDataLength.toDouble() - 1,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: _chartData,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spirometry Data')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Logged Data:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _loggedData.isEmpty ? "No data logged yet." : _loggedData,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          // Line Chart Section
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(
                    showAvg ? avgData() : mainData(),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                height: 34,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showAvg = !showAvg;
                    });
                  },
                  child: Text(
                    'avg',
                    style: TextStyle(
                      fontSize: 12,
                      color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ... rest of your UI ...
          DropdownButton<BluetoothDevice>(
            hint: const Text("Select Device"),
            value: _selectedDevice,
            items: _bluetoothService.devices.map((device) {
              return DropdownMenuItem<BluetoothDevice>(
                value: device,
                child: Text(device.name ?? "Unknown Device"),
              );
            }).toList(),
            onChanged: (BluetoothDevice? value) {
              setState(() {
                _selectedDevice = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: _isConnected ? null : _connectToDevice,
            child: Text(_isConnected ? "Connected" : "Connect to Device"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _startLogging,
                child: const Text("Start Logging"),
              ),
              ElevatedButton(
                onPressed: _stopLogging,
                child: const Text("Stop Logging"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}