import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:yaml/yaml.dart';

final ver = loadYaml(File("pubspec.yaml").readAsStringSync())["version"];

String outerName() => "ghcp_${ver}_${Platform.operatingSystem}";

String innerName() => "ghcp${Platform.isWindows ? '.exe' : ''}";

/// из файла build/ghcp.exe создаём архив build/*.zip, точное имя которого
/// зависит от версии и платформы
void main() {
  final zip = ZipFileEncoder();
  zip.create('build/${outerName()}.zip');
  zip.addFile(File('build/ghcp.exe'), innerName());
  zip.close();
}
