import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> persistSlipImage(String sourcePath) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'slips'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final dest = p.join(
    folder.path,
    '${DateTime.now().microsecondsSinceEpoch}${p.extension(sourcePath)}',
  );
  return (await File(sourcePath).copy(dest)).path;
}
