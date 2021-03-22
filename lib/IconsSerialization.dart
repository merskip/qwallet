import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/IconPicker/Packs/Cupertino.dart'
    as Cupertino;
import 'package:flutter_iconpicker/IconPicker/Packs/FontAwesome.dart'
    as FontAwesome;
import 'package:flutter_iconpicker/IconPicker/Packs/LineIcons.dart'
    as LineAwesome;
import 'package:flutter_iconpicker/IconPicker/Packs/Material.dart' as Material;
import 'package:flutter_iconpicker/IconPicker/Packs/MaterialOutline.dart'
    as MaterialOutline;
import 'package:flutter_iconpicker/Models/IconPack.dart';

Map<String, dynamic> serializeIcon(IconData icon, {IconPack? iconPack}) {
  iconPack = iconPack ?? _getInferredIconPack(icon)!;
  final iconKey = _getInferredIconKey(iconPack, icon);
  if (iconKey != null) {
    return {
      'pack': _iconPackToString(iconPack),
      'key': iconKey,
    };
  } else {
    return {
      'pack': "custom",
      'iconData': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      }
    };
  }
}

IconData? deserializeIcon(Map<String, dynamic> iconMap) {
  try {
    final pack = iconMap['pack'];
    final iconKey = iconMap['key'];
    switch (pack) {
      case "material":
        return Material.icons[iconKey];
      case "materialOutline":
        return MaterialOutline.materialOutline[iconKey];
      case "cupertino":
        return Cupertino.cupertinoIcons[iconKey];
      case "fontAwesomeIcons":
        return FontAwesome.fontAwesomeIcons[iconKey];
      case "lineAwesomeIcons":
        return LineAwesome.lineAwesomeIcons[iconKey];
      case "custom":
      default:
        return null;
    }
  } catch (e) {
    return null;
  }
}

String getIconDescription(IconData icon) {
  final iconPack = _getInferredIconPack(icon)!;
  final iconPackName = _iconPackToString(iconPack);
  final iconKey = _getInferredIconKey(iconPack, icon);
  if (iconKey != null) {
    return [
      iconPackName,
      iconKey,
    ].join(".");
  } else {
    return [
      iconPackName,
      icon.fontPackage,
      icon.fontFamily,
      icon.codePoint.toRadixString(16),
    ].join(".");
  }
}

IconPack? _getInferredIconPack(IconData icon) {
  if (icon.fontFamily == "MaterialIcons")
    return IconPack.material;
  else if (icon.fontFamily == "outline_material_icons")
    return IconPack.materialOutline;
  else if (icon.fontFamily == "CupertinoIcons")
    return IconPack.cupertino;
  else if (icon.fontPackage == "font_awesome_flutter")
    return IconPack.fontAwesomeIcons;
  else if (icon.fontPackage == "line_awesome_flutter")
    return IconPack.lineAwesomeIcons;
  else
    return IconPack.custom;
}

String _iconPackToString(IconPack iconPack) {
  switch (iconPack) {
    case IconPack.material:
      return "material";
    case IconPack.materialOutline:
      return "materialOutline";
    case IconPack.cupertino:
      return "cupertino";
    case IconPack.fontAwesomeIcons:
      return "fontAwesomeIcons";
    case IconPack.lineAwesomeIcons:
      return "lineAwesomeIcons";
    case IconPack.custom:
    default:
      return "custom";
  }
}

String? _getInferredIconKey(IconPack iconPack, IconData icon) {
  switch (iconPack) {
    case IconPack.material:
      return _getIconKey(Material.icons, icon);
    case IconPack.materialOutline:
      return _getIconKey(MaterialOutline.materialOutline, icon);
    case IconPack.cupertino:
      return _getIconKey(Cupertino.cupertinoIcons, icon);
    case IconPack.fontAwesomeIcons:
      return _getIconKey(FontAwesome.fontAwesomeIcons, icon);
    case IconPack.lineAwesomeIcons:
      return _getIconKey(LineAwesome.lineAwesomeIcons, icon);
    default:
      return null;
  }
}

String _getIconKey(Map<String, IconData> icons, IconData icon) =>
    icons.entries.firstWhere((iconEntry) => iconEntry.value == icon).key;
