import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MimeTypeIcons {
  static final Map<String, IconData> _typeIcons = {
    "text/": FontAwesomeIcons.fileAlt,
    "image/": FontAwesomeIcons.fileImage,
    "audio/": FontAwesomeIcons.fileAudio,
    "video/": FontAwesomeIcons.fileVideo,
  };

  static final Map<String, IconData> _typeSolidIcons = {
    "text/": FontAwesomeIcons.solidFileAlt,
    "image/": FontAwesomeIcons.solidFileImage,
    "audio/": FontAwesomeIcons.solidFileAudio,
    "video/": FontAwesomeIcons.solidFileVideo,
  };

  static final Map<String, IconData> _explicitIcons = {
    "application/pdf": FontAwesomeIcons.filePdf,
    "application/gzip": FontAwesomeIcons.fileArchive,
    "application/zip": FontAwesomeIcons.fileArchive,
    "application/msword": FontAwesomeIcons.fileWord,
    "application/vnd.ms-word": FontAwesomeIcons.fileWord,
    "application/vnd.oasis.opendocument.text": FontAwesomeIcons.fileWord,
    "application/vnd.openxmlformats-officedocument.wordprocessingml":
        FontAwesomeIcons.fileWord,
    "application/vnd.ms-excel": FontAwesomeIcons.fileExcel,
    "application/vnd.openxmlformats-officedocument.spreadsheetml":
        FontAwesomeIcons.fileExcel,
    "application/vnd.oasis.opendocument.spreadsheet":
        FontAwesomeIcons.fileExcel,
    "application/vnd.ms-powerpoint": FontAwesomeIcons.filePowerpoint,
    "application/vnd.openxmlformats-officedocument.presentationml":
        FontAwesomeIcons.filePowerpoint,
    "application/vnd.oasis.opendocument.presentation":
        FontAwesomeIcons.filePowerpoint,
  };

  static final Map<String, IconData> _explicitSolidIcons = {
    "application/pdf": FontAwesomeIcons.solidFilePdf,
    "application/gzip": FontAwesomeIcons.solidFileArchive,
    "application/zip": FontAwesomeIcons.solidFileArchive,
    "application/msword": FontAwesomeIcons.solidFileWord,
    "application/vnd.ms-word": FontAwesomeIcons.solidFileWord,
    "application/vnd.oasis.opendocument.text": FontAwesomeIcons.solidFileWord,
    "application/vnd.openxmlformats-officedocument.wordprocessingml":
        FontAwesomeIcons.solidFileWord,
    "application/vnd.ms-excel": FontAwesomeIcons.solidFileExcel,
    "application/vnd.openxmlformats-officedocument.spreadsheetml":
        FontAwesomeIcons.solidFileExcel,
    "application/vnd.oasis.opendocument.spreadsheet":
        FontAwesomeIcons.solidFileExcel,
    "application/vnd.ms-powerpoint": FontAwesomeIcons.solidFilePowerpoint,
    "application/vnd.openxmlformats-officedocument.presentationml":
        FontAwesomeIcons.solidFilePowerpoint,
    "application/vnd.oasis.opendocument.presentation":
        FontAwesomeIcons.solidFilePowerpoint,
  };

  MimeTypeIcons._();

  static IconData? getSolid(String? mimeType) {
    if (mimeType == null) return null;
    for (final type in _typeSolidIcons.keys) {
      if (mimeType.startsWith(type)) return _typeSolidIcons[type]!;
    }
    return _explicitSolidIcons[mimeType];
  }

  static IconData? get(String? mimeType) {
    if (mimeType == null) return null;
    for (final type in _typeIcons.keys) {
      if (mimeType.startsWith(type)) return _typeIcons[type]!;
    }
    return _explicitIcons[mimeType];
  }
}
