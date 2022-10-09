// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:yaml/yaml.dart';

String detectArchitecture(File file) {
  final stdout = Process.runSync("file", [file.path]).stdout.toString();
  bool containsAll(List<String> l) => l.every((s) => stdout.contains(s));

  if (containsAll(["Mach-O 64-bit x86_64 executable"])) {
    return "osx_x86-64";
  } if (containsAll(["Mach-O 64-bit arm64 executable"])) {
    return "osx_arm64";
  } else if (containsAll(["for GNU/Linux", "x86-64"])) {
    return "linux_x86-64";
  } else if (containsAll(["for MS Windows", "PE32+", "x86-64"])) {
    return "windows_x86-64";
  }
  throw Exception("Failed to detect the architecture");
}

final ver = loadYaml(File("pubspec.yaml").readAsStringSync())["version"];

String outerBasenameNoExt(String arch) => "ghcp_$arch";
bool isWindows(String arch) => arch.startsWith("windows");
String exeIfWindows(String arch) => isWindows(arch) ? ".exe" : "";
String innerBasename(String arch) => "ghcp${exeIfWindows(arch)}";

void toZip(File file, String innerName, String outerName) {
  final zip = ZipFileEncoder();
  zip.create('build/$outerName.zip');
  zip.addFile(file, innerName);
  zip.close();
}

void toDist(File executable) {
  final arch = detectArchitecture(executable);
  toZip(executable, innerBasename(arch), outerBasenameNoExt(arch));
}

/// из файла build/ghcp.exe создаём архив build/*.zip, точное имя которого
/// зависит от версии и платформы
void main() {
  //final arch = detectArchitecture(file);
  
//  final zip = ZipFileEncoder();
//  zip.create('build/${outerName()}.zip');
//  zip.addFile(File('build/ghcp.exe'), innerName());
//  zip.close();
}
