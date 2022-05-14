import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class PickFile extends StatefulWidget {
  const PickFile({Key key}) : super(key: key);

  @override
  State<PickFile> createState() => _PickFileState();
}

class _PickFileState extends State<PickFile> {
  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: Text("Pick File"),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles();
            if (result == null) {
              return;
            }

            // open single file

            final file = result.files.first;
            openFile(file);
            print(file.path);
          },
        ),
      ),
    );
  }
}
