// Modified by PGBHub (pgb_appflowy_editor fork of appflowy_editor 6.2.0):
// ported to the static file_picker 13 API. Licensed under MPL-2.0.
import 'package:appflowy_editor/src/editor/util/file_picker/file_picker_service.dart';
import 'package:file_picker/file_picker.dart' as fp;

class FilePicker implements FilePickerService {
  @override
  Future<String?> getDirectoryPath({String? title}) {
    return fp.FilePicker.getDirectoryPath(dialogTitle: title);
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    Function(fp.FilePickerStatus p1)? onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    // file_picker 13 always allows several files and reads lazily
    // (`PlatformFile.readAsBytes`), so `withData`/`withReadStream` are moot.
    final files = await fp.FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
    );
    return FilePickerResult(
      allowMultiple ? files : files.take(1).toList(),
    );
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async {
    // file_picker 13 saves bytes itself (no path-only save dialog); the editor
    // core never calls this.
    return null;
  }
}
