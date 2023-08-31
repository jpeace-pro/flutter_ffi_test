import 'dart:math';
import 'dart:ui';
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
    final xLabels = [-30, -5, -2, -1, -0.5, -0.2, 0.0, 0.2, 0.5, 1, 2, 5, 30];
    for (var i = 0; i < xLabels.length; i++) {
      // Zero case
      if (xLabels[i] == 0.0) {
        // j0
        canvas.drawLine(
            Offset(0, size.height / 2),
            Offset(size.width, size.height / 2),
            Paint()..strokeWidth = webLineWidth);
      } else {
        // Positive Arcs
        canvas.drawArc(
            Rect.fromCenter(
                center:
                    Offset(size.width, center.dy - ((center.dy / xLabels[i]))),
                width: size.width / xLabels[i],
                height: size.height / xLabels[i]),
            pi,
            2 * pi,
            false,
            Paint()
              ..strokeWidth = webLineWidth
              ..style = PaintingStyle.stroke);
        // Negative
        canvas.drawArc(
            Rect.fromCenter(
                center:
                    Offset(size.width, center.dy + ((center.dy / xLabels[i]))),
                width: size.width / xLabels[i],
                height: size.height / xLabels[i]),
            pi,
            2 * pi,
            false,
            Paint()
              ..strokeWidth = webLineWidth
              ..style = PaintingStyle.stroke);
      }
    }

    void calculateIntersection(Point p1, Point p2, r1, r2) {
      var x1 = p1.x; // center of circle 1
      var y1 = p1.y;
      var x2 = p2.x;
      var y2 = p2.y;

      var distance = sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2));
      if (distance == r1 + r2 || distance < r1 + r2) {
        // there is a single intersection point
        // or
        // there are two intersection points
        var a = (pow(r1, 2) - pow(r2, 2) + pow(distance, 2)) / (2 * distance);
        var b = (pow(r2, 2) - pow(r1, 2) + pow(distance, 2)) / (2 * distance);
        var h = sqrt(pow(r1, 2) - pow(a, 2));
        var x5 = x1 + (a / distance) * (x2 - x1);
        var y5 = y1 + (a / distance) * (y2 - y1);
        var x3 = x5 - ((h * (y2 - y1)) / distance);
        var y3 = y5 + ((h * (x2 - x1)) / distance);
        var x4 = x5 + ((h * (y2 - y1)) / distance);
        var y4 = y5 - ((h * (x2 - x1)) / distance);

        canvas.drawPoints(
            PointMode.points,
            // [const Offset(0, 0), Offset(1, 2), Offset(200, 600)],
            [Offset(x5, y5), Offset(x4, y4), Offset(x3, y3)],
            Paint()
              ..strokeWidth = 40
              ..color = Colors.purpleAccent
              ..strokeCap = StrokeCap.round);
      }
    }

    calculateIntersection(
        Point(((2 * center.dx) - (center.dx * (1 / (1 + 0.7)))),
            center.dy), //ylabels RESISTANCE
        Point(2 * center.dx,
            center.dy + ((center.dy / -0.63))), //xlabels REACTANCE
        radius * (1 / (1 + 0.71)),
        (size.width / 0.63) / 2);

    // calculateIntersection(Point(size.width, center.dy + ((center.dy / 2))),
    //     Point(((2 * radius) - (radius * (1 / (1 + 5)))), center.dy), 1, 2);

    // var paath = Path();
    // paath.addOval(Rect.fromCenter(
    //     center: Offset(size.width, center.dy + ((center.dy / -0.63))),
    //     width: size.width / 0.63,
    //     height: size.height / 0.63));
    // canvas.drawPath(
    //     paath,
    //     Paint()
    //       ..strokeWidth = 10
    //       ..color = Colors.blue
    //       ..style = PaintingStyle.stroke);
    // var paaath = Path();
    // paaath.addOval(Rect.fromCenter(
    //     // center: Offset((center.dx - (center.dx / (1 + 0.7))), center.dy),
    //     center: Offset(center.dx + ((1 / (1 + 0.7))), center.dy),
    //     width: (size.width / (1 + 0.7)),
    //     height: (size.width / (1 + 0.7))));
    // canvas.drawPath(
    //     paaath,
    //     Paint()
    //       ..strokeWidth = 10
    //       ..color = Colors.red
    //       ..style = PaintingStyle.stroke);

    // final shape = Path.combine(PathOperation.intersect, paath, paaath);
    // canvas.clipPath(shape);

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, center.dy + ((center.dy / -0.63))),
            width: size.width / 0.63,
            height: size.height / 0.63), // take the absolute value i guess
        pi,
        2 * pi,
        false,
        Paint()
          ..strokeWidth = 10
          ..color = Colors.blue
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(
        Offset(((2 * radius) - (radius * (1 / (1 + 0.7)))), center.dy),
        radius * (1 / (1 + 0.7)),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke);

    // RESISTANCE LINES
    final yLabels = [0.0, 0.2, 0.5, 1, 2, 5, 30];
    for (var i = 0; i <= yLabelCount; i++) {
      canvas.drawCircle(
          Offset(((2 * radius) - (radius * (1 / (1 + yLabels[i])))), center.dy),
          radius * (1 / (1 + yLabels[i])),
          Paint()
            ..color = webLineColor
            ..strokeWidth = webLineWidth
            ..style = PaintingStyle.stroke);
    }

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

      final textPainter = TextPainter()
        ..text = TextSpan(
            text: yLabels[i],
            style: TextStyle(color: yLabelColor, fontSize: yLabelSize))
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      textPainter.paint(canvas, Offset(y1 * 2 - (center.dx / 20), center.dy));
    }
  }

  void drawData(Canvas canvas, int axisCount, double radius, Offset center) {
    // need to draw each component of the equation in an x y ish type coordinate.
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
