import 'package:flutter/material.dart';

class BloodPressureChart extends StatelessWidget {
  final int systolic;
  final int diastolic;

  const BloodPressureChart({
    Key? key,
    required this.systolic,
    required this.diastolic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String category = getBloodPressureCategory();
    // Use SafeArea to ensure content is within the safe zone
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Table(
              border: TableBorder.all(color: Colors.blueGrey),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(100),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    _buildTableCell('Stage', isHeader: true),
                    _buildTableCell('Systolic', isHeader: true),
                    _buildTableCell('Diastolic', isHeader: true),
                  ],
                ),
                ...buildTableRows(context, category),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Rows in table-(details)
  List<TableRow> buildTableRows(BuildContext context, String category) {
    List<Map<String, dynamic>> stages = [
      {
        'stage': 'Low',
        'systolic': '40 - 90',
        'diastolic': '40 - 60',
        'color': Colors.lightBlue[100]
      },
      {
        'stage': 'Normal',
        'systolic': '90 - 120',
        'diastolic': '60 - 80',
        'color': Colors.green[100]
      },
      {
        'stage': 'Prehypertension',
        'systolic': '120 - 140',
        'diastolic': '80 - 90',
        'color': Colors.yellow[100]
      },
      {
        'stage': 'High: Stage 1',
        'systolic': '140 - 160',
        'diastolic': '90 - 100',
        'color': Colors.orange[100]
      },
      {
        'stage': 'High: Stage 2',
        'systolic': '160 - 180+',
        'diastolic': '100 - 120+',
        'color': Colors.red[100]
      },
    ];

    return stages.map<TableRow>((stageInfo) {
      bool isCurrentStage = stageInfo['stage'] == category;
      return TableRow(
        decoration: BoxDecoration(
          color: stageInfo['color'],
          // Add a red line margin if it's the current stage
          border:
              isCurrentStage ? Border.all(color: Colors.red, width: 2) : null,
        ),
        children: <Widget>[
          _buildBlinkingCell(stageInfo['stage'], isCurrentStage),
          _buildBlinkingCell(stageInfo['systolic'], isCurrentStage),
          _buildBlinkingCell(stageInfo['diastolic'], isCurrentStage),
        ],
      );
    }).toList();
  }

  Widget _buildTableCell(String text,
      {bool isHighlighted = false, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? null : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBlinkingCell(String text, bool isBlinking) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedOpacity(
        opacity: isBlinking ? 1.0 : 0.5,
        duration: Duration(seconds: 1),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
          textAlign: TextAlign.center,
        ),
        // Make the cell blink by looping the animation
        onEnd: () => _buildBlinkingCell(text, isBlinking),
      ),
    );
  }

  String getBloodPressureCategory() {
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
}
