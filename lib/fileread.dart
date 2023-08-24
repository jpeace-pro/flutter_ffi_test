import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileReader {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt'); // this should be the s1p file
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<int> dlmRead() async {
    //dlmread('filepath','',5,0)
    // https://www.mathworks.com/help/matlab/ref/dlmread.html
    // reads and ASCII-delimited numeric data file into matrix M
    // filename, delimiter, r1, c1
    // r1 row offset
    // c1 col offset
    // need to figure out how to make n x m array from column
    // take a look at using smart_arrays_numerics 2.1.1
    // https://pub.dev/packages/smart_arrays_numerics/example
    // CalS = dlmread('','',5,0)
    return 0;
  }

  Future<int> smithMeasurement() async {
    // Need to use Complex class
    // https://pub.dev/documentation/quantity/latest/number/Complex-class.html
    // https://www.mathworks.com/help/matlab/ref/j.html
    // j is sqrt(-1)
    // Gam_MS=CalS(:,2)+1j*CalS(:,3);
    // This defines the reflection parameters from Short, Open, Load measurements...
    // Each variable is a (ind x 1) matrix
    // Result from this can be represented in rectangular coordinates: A + jB
    // I think we would then just plot the A and jB components against the graph...now how do we mathematically do that?
    return 0;
  }

  // Create a function that puts dlmRead and smithMeasurement together and assigns a label
  // The result of this function will be used for the legend on the smithplot
}
