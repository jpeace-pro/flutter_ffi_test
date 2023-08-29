import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:matrices/matrices.dart';

class FileReader {
  late File filepath;
  late String delimiter;
  late int r1;
  late int c1;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(filepath) async {
    final path = await _localPath;
    return File(
        // '$path/Open_black_cable_85033E_brd.s1p'
        'D:\\Programming\\GitHub\\flutter_ffi_test\\lib\\Open_black_cable_85033E_brd.s1p'); // this should be the s1p file
    // return File('$path/$filepath'); // this should be the s1p file
    // return File('$filepath'); // this should be the s1p file
  }

  Future<int> readCounter(filepath) async {
    try {
      final file = await _localFile(filepath);
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<List<List<double>>> dlmRead(filepath, delimiter, r1, c1) async {
    //dlmread('filepath','',5,0)
    // https://www.mathworks.com/help/matlab/ref/dlmread.html
    // reads and ASCII-delimited numeric data file into matrix M
    // filename, delimiter, r1, c1
    // r1 row offset
    // c1 col offset
    try {
      final file = await _localFile(filepath);
      final contents = await file.readAsLines();
      final rows = contents.sublist(r1);
      List<List<double>> mat = [];
      // need to figure out how to make n x m array from column
      // take a look at using smart_arrays_numerics 2.1.1
      // https://pub.dev/packages/smart_arrays_numerics/example
      // CalS = dlmread('','',5,0)
      for (var i = 0; i < rows.length; i++) {
        var matrow = rows[i]
            .split(delimiter)
            .map((String value) => double.parse(value))
            .toList();
        mat.add(matrow);
      }
      ;
      return mat;
      // return int.parse(contents);
    } catch (e) {
      return [
        [0.2]
      ];
    }
  }

  Future<List<double>> smithMeasurement() async {
    // Need to use Complex class
    // https://pub.dev/documentation/quantity/latest/number/Complex-class.html
    // https://www.mathworks.com/help/matlab/ref/j.html
    // j is sqrt(-1)
    // Gam_MS=CalS(:,2)+1j*CalS(:,3);
    // This defines the reflection parameters from Short, Open, Load measurements...
    // Each variable is a (ind x 1) matrix
    final matrix = await dlmRead(
        'D:\Programming\GitHub\flutter_ffi_test\lib\Open_black_cable_85033E_brd.s1p',
        // 'Users/janaispeace/Desktop/trove/GitHub/flutter_ffi_test/lib/Open_black_cable_85033E_brd.s1p',
        ' ',
        5,
        0);
    final mat = Matrix.fromList(matrix);
    var gam = mat.column(1) +
        (mat.column(2)); // Do we actually need to multiply by j or just infer
    // var gam1 = mat.column(1);
    // var gam2 = mat.column(2);

    // Result from this can be represented in rectangular coordinates: A + jB
    // I think we would then just plot the A and jB components against the graph...now how do we mathematically do that?
    return gam;
  }

  // Create a function that puts dlmRead and smithMeasurement together and assigns a label
  // The result of this function will be used for the legend on the smithplot
}
