// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Считает хэш так же, как это делает GH. Возвращает hexdigest.
String bytesToGhSha(Uint8List bytes) =>
    sha1.convert(ascii.encode("blob ${bytes.length}\u0000") + bytes).toString();

String fileToGhSha(File file) => bytesToGhSha(file.readAsBytesSync());
