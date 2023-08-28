import 'dart:math';
import 'package:flutter/material.dart';
import 'smithchartdata.dart';
import 'valueformatter.dart';

class SmithChart extends StatefulWidget {
  const SmithChart(
      {this.bgColor = Colors.black12,
      this.webLineWidth = 0.0,
      this.webLineColor = Colors.black,
      this.markerSize = 0.0,
      this.xDrawLabels = false,
      this.xLabels,
      this.xLabelColor = Colors.black,
      this.xLabelSize = 10,
      this.yMaximum = 100.0,
      this.yValueFormatter,
      this.yLabelCount = 6,
      this.yLabelColor = Colors.black,
      this.yLabelSize = 10,
      this.yDrawLabels = false,
      required this.data,
      super.key});
  final Color bgColor;
  final double webLineWidth;
  final Color webLineColor;
  final double markerSize;
  final bool xDrawLabels;
  final List<String>? xLabels;
  final Color xLabelColor;
  final double xLabelSize;
  final double yMaximum;
  final ValueFormatter? yValueFormatter;
  final int yLabelCount;
  final Color yLabelColor;
  final double yLabelSize;
  final bool yDrawLabels;
  final RadarData data;

  @override
  State<StatefulWidget> createState() => _RadarChartState();
}

class _RadarChartState extends State<SmithChart> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarChartCustomPainter(
        bgColor: widget.bgColor,
        webLineWidth: widget.webLineWidth,
        webLineColor: widget.webLineColor,
        markerSize: widget.markerSize,
        xDrawLabels: widget.xDrawLabels,
        xLabels: widget.xLabels,
        xLabelColor: widget.xLabelColor,
        xLabelSize: widget.xLabelSize,
        yMaximum: widget.yMaximum,
        yValueFormatter: widget.yValueFormatter,
        yLabelCount: widget.yLabelCount,
        yLabelColor: widget.yLabelColor,
        yLabelSize: widget.yLabelSize,
        yDrawLabels: widget.yDrawLabels,
        data: widget.data,
      ),
    );
  }
}

class _RadarChartCustomPainter extends CustomPainter {
  static const _offsetAngle = 90;

  num sinDeg(num degree) => sin(degToRad(degree));

  num cosDeg(num degree) => cos(degToRad(degree));

  num tanDeg(num degree) => tan(degToRad(degree));

  num degToRad(num degree) => degree * pi / 180;

  Offset modifiedOffset(Size size, Offset offset, double width, double height) {
    double dx = offset.dx - width / 2;
    double dy = offset.dy - height / 2;

    if (dx < 0) {
      dx = 0;
    } else if (dx + width > size.width) {
      dx = size.width - width;
    }

    if (dy < 0) {
      dy = 0;
    } else if (dy + height > size.height) {
      dy = size.height - height;
    }

    return Offset(dx, dy);
  }

  _RadarChartCustomPainter({
    required this.bgColor,
    required this.webLineWidth,
    required this.webLineColor,
    required this.markerSize,
    required this.xDrawLabels,
    required this.xLabels,
    required this.xLabelColor,
    required this.xLabelSize,
    required this.yMaximum,
    required this.yValueFormatter,
    required this.yLabelCount,
    required this.yLabelColor,
    required this.yLabelSize,
    required this.yDrawLabels,
    required this.data,
  });

  final Color bgColor;
  final double webLineWidth;
  final Color webLineColor;
  final double markerSize;
  final bool xDrawLabels;
  final List<String>? xLabels;
  final Color xLabelColor;
  final double xLabelSize;
  final double yMaximum;
  final ValueFormatter? yValueFormatter;
  final int yLabelCount;
  final Color yLabelColor;
  final double yLabelSize;
  final bool yDrawLabels;
  final RadarData data;

  // https://www.allaboutcircuits.com/technical-articles/mathematical-construction-and-properties-of-the-smith-chart/#:~:text=Setting%20R%20%3D%200%20will%20result,often%20called%20the%20real%20axis.

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        min(size.width, size.height) / 2 - (xDrawLabels ? xLabelSize : 0);
    final axisCount =
        data.dataSets.isNotEmpty ? data.dataSets[0].entries.length : 0;
    final rect =
        Rect.fromCenter(center: center, width: size.width, height: size.height);

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgColor);

    // Smith
    // REACTANCE LINES
    // j0
    canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        Paint()..strokeWidth = webLineWidth);
    // j0.2
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, -size.height * 2),
            width: size.width / 0.2,
            height: size.height / 0.2),
        pi * 0.1255,
        pi / 2,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height * 3),
            width: size.width / 0.2,
            height: size.height / 0.2),
        5 * pi / 3.638,
        pi / 1.7,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // j0.5
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, -size.height / 2),
            width: size.width / 0.5,
            height: size.height / 0.5),
        pi / 0.3,
        2 * pi / 1.368,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 0.667),
            width: size.width / 0.5,
            height: size.height / 0.5),
        pi / 0.312,
        2 * pi / 2.5,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // j1
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 900),
            width: size.width,
            height: size.height),
        pi / 2,
        2 * pi / 4,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 1),
            width: size.width,
            height: size.height),
        pi / 0.358,
        2 * pi / 2.5,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // j2
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 4),
            width: size.width / 2,
            height: size.height / 2),
        pi / 2,
        2 * pi / 2.84,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 1.336),
            width: size.width / 2,
            height: size.height / 2),
        pi / 0.358,
        2 * pi / 2.5,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // j5
    canvas.drawArc(
        // rect,
        // Rect.fromPoints(Offset(size.width / 2, size.height / 1000),
        //     Offset(size.width, size.height / 2)),
        Rect.fromCenter(
            center: Offset(size.width, size.height / 2.5),
            width: size.width / 5,
            height: size.height / 5),
        pi / 2, // rotates the arc
        2 * pi / 2.29, // increases amount of arc
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        // rect,
        Rect.fromCenter(
            center: Offset(size.width, size.height / 1.67),
            width: size.width / 5,
            height: size.height / 5),
        pi / 0.38, // rotates the arc
        2 * pi / 2.29,
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // j30
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height / 2.07),
            width: size.width / 30,
            height: size.height / 30),
        pi / 2, // rotates the arc
        2 * pi, // increases amount of arc
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    canvas.drawArc(
        // rect,
        Rect.fromCenter(
            center: Offset(size.width, size.height / 1.935),
            width: size.width / 30,
            height: size.height / 30),
        pi / 0.377, // rotates the arc
        2 * pi, //
        false,
        Paint()
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);

    // RESISTANCE LINES
    // Outer 1 0.0
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 0.2
    canvas.drawCircle(
        Offset(size.width / 1.71, size.height / 2),
        radius * (1 / 1.2), // radius calculated by (1 / (frequency + 1))
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 0.5
    canvas.drawCircle(
        Offset(size.width / 1.5, size.height / 2),
        radius * (1 / 1.5),
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 1
    canvas.drawCircle(
        Offset(size.width / 1.33, size.height / 2),
        radius * (1 / 2),
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 2
    canvas.drawCircle(
        Offset(size.width / 1.2, size.height / 2),
        radius * (1 / 3),
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 5
    canvas.drawCircle(
        Offset(size.width / 1.087, size.height / 2),
        radius * (1 / 6),
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);
    // 30
    canvas.drawCircle(
        Offset(size.width / 1.015, size.height / 2),
        radius * (1 / 31),
        Paint()
          ..color = webLineColor
          ..strokeWidth = webLineWidth
          ..style = PaintingStyle.stroke);

    //
    // drawGuideLines(canvas, axisCount, radius, center);

    //
    // drawAxis(canvas, axisCount, radius, center);

    //
    drawData(canvas, axisCount, radius, center);

    //
    if (xDrawLabels) {
      drawXLabels(canvas, size, axisCount, radius + yLabelSize, center);
    }

    //
    if (yDrawLabels) {
      drawYLabels(canvas, size, axisCount, radius, center);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void drawGuideLines(
      // Canvas canvas, int axisCount, double radius, Offset center) {
      //   final thisRadius = radius * i / 7;
      //   canvas.drawLine(
      //     Paint()
      //       ..strokeWidth = webLineWidth
      //       ..color = webLineColor);
      // }

      Canvas canvas,
      int axisCount,
      double radius,
      Offset center) {
    for (var i = 1; i <= yLabelCount; i++) {
      for (var j = 0; j < axisCount; j++) {
        final thisRadius = radius * i / yLabelCount;
        final startAngle = _offsetAngle - 360 / axisCount * j;
        final endAngle = _offsetAngle - 360 / axisCount * (j + 1);
        // P1
        final x1 = center.dx + thisRadius * cosDeg(startAngle);
        final y1 = center.dy - thisRadius * sinDeg(startAngle);
        // P2
        final x2 = center.dx + thisRadius * cosDeg(endAngle);
        final y2 = center.dy - thisRadius * sinDeg(endAngle);

        canvas.drawLine(
            Offset(x1, y1),
            Offset(x2, y2),
            Paint()
              ..strokeWidth = webLineWidth
              ..color = webLineColor);
      }
    }
  }

  void drawAxis(Canvas canvas, int axisCount, double radius, Offset center) {
    for (var i = 0; i < axisCount; i++) {
      final startAngle = _offsetAngle - 360 / axisCount * i;
      final x1 = center.dx + radius * cosDeg(startAngle);
      final y1 = center.dy - radius * sinDeg(startAngle);

      canvas.drawLine(
          Offset(x1, y1),
          center,
          Paint()
            ..strokeWidth = webLineWidth
            ..color = webLineColor);
    }
  }

  // void drawXLabels(
  //     Canvas canvas, Size size, int axisCount, double radius, Offset center) {
  //   for (var i = 0; i < (xLabels?.length ?? 0); i++) {
  //     final startAngle = _offsetAngle - 360 / axisCount * i;
  //     final x1 = center.dx + radius * cosDeg(startAngle);
  //     final y1 = center.dy - radius * sinDeg(startAngle);

  //     final textPainter = TextPainter()
  //       ..text = TextSpan(
  //           text: xLabels![i],
  //           style: TextStyle(color: xLabelColor, fontSize: xLabelSize))
  //       ..textDirection = TextDirection.ltr
  //       ..textAlign = TextAlign.center
  //       ..layout();

  //     textPainter.paint(
  //         canvas,
  //         modifiedOffset(
  //             size, Offset(x1, y1), textPainter.width, textPainter.height));
  //   }
  // }

  // void drawYLabels(
  //     Canvas canvas, Size size, int axisCount, double radius, Offset center) {
  //   final x1 = center.dx + radius * cosDeg(_offsetAngle);
  //   for (var i = 1; i <= yLabelCount; i++) {
  //     final y1 = center.dy -
  //         radius / yLabelCount * (yLabelCount - i) * sinDeg(_offsetAngle);

  //     final textPainter = TextPainter()
  //       ..text = TextSpan(
  //           text: yValueFormatter != null
  //               ? yValueFormatter!
  //                   .format(yMaximum / yLabelCount * (yLabelCount - i))
  //               : (yMaximum / yLabelCount * (yLabelCount - i)).toString(),
  //           style: TextStyle(color: yLabelColor, fontSize: yLabelSize))
  //       ..textDirection = TextDirection.ltr
  //       ..textAlign = TextAlign.center
  //       ..layout();

  //     textPainter.paint(
  //         canvas, Offset(x1 + webLineWidth, y1 - textPainter.height / 2));
  //   }
  // }
  // )

  void drawXLabels(
      Canvas canvas, Size size, int axisCount, double radius, Offset center) {
    final xLabels = ['0.0', 'j0.2', 'j0.5', 'j1', 'j2', 'j5', 'j30'];
    // for (var i = 0; i <= 7; i++) {
    //   final textPainter = TextPainter()
    //     ..text = TextSpan(
    //         text: xLabels[i],
    //         style: TextStyle(color: yLabelColor, fontSize: yLabelSize))
    //     ..textDirection = TextDirection.ltr
    //     ..textAlign = TextAlign.center
    //     ..layout();

    //   textPainter.paint(canvas, Offset(center.dx, center.dy));
    // }
  }

  void drawYLabels(
      Canvas canvas, Size size, int axisCount, double radius, Offset center) {
    final x1 = center.dx + radius * cosDeg(_offsetAngle);
    final yLabels = ['0.0', '0.2', '0.5', '1', '2', '5', '30'];
    for (var i = 0; i <= yLabelCount; i++) {
      final y1 = center.dy -
          radius / yLabelCount * (yLabelCount - i) * sinDeg(_offsetAngle);
      // final y1 = center.dy -
      //     radius / yLabelCount * (yLabelCount - i) * sinDeg(_offsetAngle);

      // final textPainter = TextPainter()
      //   ..text = TextSpan(
      //       text: yValueFormatter != null
      //           ? yValueFormatter!
      //               .format(yMaximum / yLabelCount * (yLabelCount - i))
      //           : (yMaximum / yLabelCount * (yLabelCount - i)).toString(),
      //       style: TextStyle(color: yLabelColor, fontSize: yLabelSize))
      //   ..textDirection = TextDirection.ltr
      //   ..textAlign = TextAlign.center
      //   ..layout();

      final textPainter = TextPainter()
        ..text = TextSpan(
            text: yLabels[i],
            style: TextStyle(color: yLabelColor, fontSize: yLabelSize))
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      textPainter.paint(canvas, Offset(y1 * 2 - (center.dx / 20), center.dy));
      // canvas, Offset(x1 + webLineWidth, y1 - textPainter.height / 2));
    }
  }

  void drawData(Canvas canvas, int axisCount, double radius, Offset center) {
    for (var i = 0; i < data.dataSets.length; i++) {
      final entry = data.dataSets[i];
      final fillPath = Path();
      for (var j = 0; j < entry.entries.length; j++) {
        final v1 = entry.entries[j].value;
        final v2 =
            entry.entries[j == entry.entries.length - 1 ? 0 : j + 1].value;
        final startAngle = _offsetAngle - 360 / axisCount * j;
        final endAngle = _offsetAngle - 360 / axisCount * (j + 1);

        // P1
        final x1 = center.dx + (radius * v1 / yMaximum) * cosDeg(startAngle);
        final y1 = center.dy - (radius * v1 / yMaximum) * sinDeg(startAngle);
        // P2
        final x2 = center.dx + (radius * v2 / yMaximum) * cosDeg(endAngle);
        final y2 = center.dy - (radius * v2 / yMaximum) * sinDeg(endAngle);

        canvas.drawLine(
            Offset(x1, y1),
            Offset(x2, y2),
            Paint()
              ..strokeWidth = entry.lineWidth
              ..color = entry.color);

        if (markerSize > 0.0) {
          canvas.drawCircle(
              Offset(x1, y1), markerSize, Paint()..color = entry.color);
        }

        if (j == 0) {
          fillPath.moveTo(x1, y1);
        } else {
          fillPath.lineTo(x1, y1);
        }
      }
      canvas.drawPath(fillPath, Paint()..color = entry.fillColor);
    }
  }
}
