import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/IconPack.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/api/Category.dart';

import '../AppLocalizations.dart';
import 'ColorPicker.dart';
import 'PrimaryButton.dart';

class CategoryForm extends StatefulWidget {
  final Category category;

  final Function(
    BuildContext context,
    String title,
    Color primaryColor,
    Color backgroundColor,
    IconData icon,
  ) onSubmit;

  final Widget submitChild;

  const CategoryForm({
    Key key,
    this.category,
    this.onSubmit,
    this.submitChild,
  }) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState(category: category);
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();

  final titleController;
  final titleFocus = FocusNode();

  MaterialColor primaryColor = Colors.primaries.first;
  bool backgroundColorIsPrimary;
  MaterialColor backgroundColor;
  IconData icon;

  _CategoryFormState({Category category})
      : titleController = TextEditingController(text: category?.title),
        primaryColor = _findMaterialColor(category?.primaryColor, 800) ??
            Colors.primaries.first,
        backgroundColor = _findMaterialColor(category?.backgroundColor, 100) ??
            Colors.primaries.first,
        icon = category?.icon ?? Icons.category {
    backgroundColorIsPrimary = (primaryColor == backgroundColor);
  }

  static MaterialColor _findMaterialColor(Color color, int shade) {
    if (color == null) return color;
    return Colors.primaries.firstWhere(
      (materialColor) => materialColor[shade] == color,
      orElse: () => null,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocus.dispose();
    super.dispose();
  }

  onSelectedIcon(BuildContext context) async {
    IconData icon = await _showIconPicker(context);
    if (icon != null) {
      iconDataToMap(icon);
      setState(() => this.icon = icon);
    }
  }

  onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      if (widget.onSubmit != null)
        widget.onSubmit(
          context,
          titleController.text.trim(),
          primaryColor.shade800,
          backgroundColor.shade100,
          icon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildTitleField(context),
        buildIconPreview(context),
        buildPrimaryColorPicker(context),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Divider(),
        ),
        buildBackgroundColorPicker(context),
        buildSubmit(context),
      ]),
    );
  }

  Widget buildTitleField(BuildContext context) {
    return TextFormField(
      controller: titleController,
      focusNode: titleFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).categoryTitle,
      ),
      autofocus: widget.category == null,
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      validator: (title) {
        if (title.trim().isEmpty) {
          return AppLocalizations.of(context).categoryTitleErrorEmpty;
        }
        return null;
      },
      onFieldSubmitted: (title) => titleFocus.unfocus(),
    );
  }

  Widget buildIconPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Tooltip(
        message: AppLocalizations.of(context).categoryIconHint,
        child: GestureDetector(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: backgroundColor.shade100,
                child: Center(
                  child: Icon(
                    icon,
                    color: primaryColor.shade800,
                    size: 48,
                  ),
                ),
                radius: 48,
              ),
              SizedBox(height: 6),
              Text(
                getIconDescription(icon),
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          onTap: () => onSelectedIcon(context),
        ),
      ),
    );
  }

  Widget buildPrimaryColorPicker(BuildContext context) {
    return ColorPicker(
      colors: Colors.primaries,
      selectedColor: primaryColor,
      onChangeColor: (color) => setState(() {
        this.primaryColor = color;
        if (backgroundColorIsPrimary) this.backgroundColor = color;
      }),
    );
  }

  Widget buildBackgroundColorPicker(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
            title: Text(
                AppLocalizations.of(context).categoryBackgroundColorIsPrimary),
            value: backgroundColorIsPrimary,
            onChanged: (flag) => setState(() {
                  backgroundColorIsPrimary = flag;
                  if (backgroundColorIsPrimary) backgroundColor = primaryColor;
                })),
        if (!backgroundColorIsPrimary)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ColorPicker(
              colors: Colors.primaries,
              selectedColor: backgroundColor,
              onChangeColor: (color) =>
                  setState(() => this.backgroundColor = color),
            ),
          ),
      ],
    );
  }

  Widget buildSubmit(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PrimaryButton(
        child: widget.submitChild,
        onPressed: () => onSelectedSubmit(context),
      ),
    );
  }

  Future<IconData> _showIconPicker(BuildContext context) async {
    final IconPack iconPack = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context).categoryIconPackSelect),
        children: [
          buildIconPackItem(context, IconPack.material),
          buildIconPackItem(context, IconPack.materialOutline),
          buildIconPackItem(context, IconPack.cupertino),
          buildIconPackItem(context, IconPack.fontAwesomeIcons),
          buildIconPackItem(context, IconPack.lineAwesomeIcons),
        ],
      ),
    );
    if (iconPack == null) return null;

    IconData icon = await FlutterIconPicker.showIconPicker(
      context,
      showTooltips: true,
      adaptiveDialog: true,
      title: Text(_getIconPackTitle(iconPack)),
      searchHintText: AppLocalizations.of(context).categoryIconPackSearch,
      noResultsText: AppLocalizations.of(context).categoryIconPackSearchEmpty,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      iconPackMode: iconPack,
    );
    return icon;
  }

  Widget buildIconPackItem(BuildContext context, IconPack iconPack) {
    return ListTile(
      title: Text(_getIconPackTitle(iconPack)),
      onTap: () => Navigator.of(context).pop(iconPack),
    );
  }

  String _getIconPackTitle(IconPack iconPack) {
    switch (iconPack) {
      case IconPack.material:
        return AppLocalizations.of(context).categoryIconPackMaterial;
      case IconPack.materialOutline:
        return AppLocalizations.of(context).categoryIconPackMaterialOutline;
      case IconPack.cupertino:
        return AppLocalizations.of(context).categoryIconPackCupertino;
      case IconPack.fontAwesomeIcons:
        return AppLocalizations.of(context).categoryIconPackFontAwesome;
      case IconPack.lineAwesomeIcons:
        return AppLocalizations.of(context).categoryIconPackLineAwesome;
      default:
        return null;
    }
  }
}
