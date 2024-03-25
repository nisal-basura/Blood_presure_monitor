import 'dart:math' as math;

/// For circular motion
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

/// For BackdropFilter
import 'chart.dart';

/// dart files for display table

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Pressure Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent, // Default color for buttons
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 80, end: 100).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToInformationScreen() {
    int? systolic = int.tryParse(systolicController.text);
    int? diastolic = int.tryParse(diastolicController.text);

    if (systolic == null ||
        diastolic == null ||
        systolic < 40 ||
        diastolic < 40) {
      Get.snackbar(
        'Invalid Input',
        '', // Empty string because we are using messageText for the content.
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color.fromARGB(255, 234, 139, 139),
        messageText: Text.rich(
          TextSpan(
            text:
                'Please enter valid numbers for both systolic and diastolic values that are ',
            style: TextStyle(color: Colors.black),

            /// Default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'greater than or equal to 40.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          style: TextStyle(color: Colors.white),

          /// Overall TextStyle
        ),
      );
    } else {
      Get.to(() => InformationScreen(systolic: systolic, diastolic: diastolic));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Pressure Monitor'),
        backgroundColor: Color.fromARGB(255, 207, 171, 171),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100]?.withOpacity(0.3),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          30 * math.cos(_rotationAnimation.value),
                          30 * math.sin(_rotationAnimation.value),
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: _sizeAnimation.value,
                          color: Colors.redAccent,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextFormField(
                      controller: systolicController,
                      keyboardType: TextInputType.number,

                      /// Number pad
                      decoration: InputDecoration(
                        labelText: 'Systolic (mm Hg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: diastolicController,
                      keyboardType: TextInputType.number,

                      /// Number pad
                      decoration: InputDecoration(
                        labelText: 'Diastolic (mm Hg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: navigateToInformationScreen,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,

                        /// Button color
                        onPrimary: Colors.white,

                        ///Text color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),

                        /// Button padding
                      ),
                      child: Text('Show Info', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InformationScreen extends StatelessWidget {
  final int systolic;
  final int diastolic;

  InformationScreen({required this.systolic, required this.diastolic});

  @override
  Widget build(BuildContext context) {
    String category = getBloodPressureCategory(systolic, diastolic);
    Color categoryColor = getCategoryColor(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Pressure Category'),
        backgroundColor: categoryColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          /// Distribute space evenly
          children: [
            // Texts Container for better spacing control
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'Systolic blood pressure is $systolic mm Hg',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  /// Visual spacing
                  Text(
                    'Diastolic blood pressure is $diastolic mm Hg',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  /// Visual spacing
                  Text(
                    'This is considered $category.',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: categoryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            /// BloodPressureChart with flexible widget to ensure it occupies appropriate space
            Flexible(
              child:
                  BloodPressureChart(systolic: systolic, diastolic: diastolic),
            ),
          ],
        ),
      ),
    );
  }

  String getBloodPressureCategory(int systolic, int diastolic) {
    /// Logic remains the same as before
    if (systolic < 90 && diastolic < 60) {
      return 'Low';
    } else if (systolic <= 120 && diastolic <= 80) {
      return 'Normal';
    } else if (systolic <= 140 || diastolic <= 90) {
      return 'Prehypertension';
    } else if (systolic <= 160 || diastolic <= 100) {
      return 'High: Stage 1';
    } else {
      return 'High: Stage 2';
    }
  }

  Color getCategoryColor(String category) {
    /// Logic remains the same as before
    switch (category) {
      case 'Low':
        return Colors.lightBlueAccent;
      case 'Normal':
        return Colors.green;
      case 'Prehypertension':
        return Colors.yellow;
      case 'High: Stage 1':
        return Colors.orange;
      case 'High: Stage 2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
