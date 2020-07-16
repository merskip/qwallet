import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/ColorPicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

class AddCategoryPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const AddCategoryPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add category"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddCategoryForm(walletRef: walletRef),
        ),
      ),
    );
  }
}

class _AddCategoryForm extends StatefulWidget {
  final Reference<Wallet> walletRef;

  const _AddCategoryForm({Key key, this.walletRef}) : super(key: key);

  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<_AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final titleFocus = FocusNode();

  MaterialColor primaryColor = Colors.primaries.first;
  bool backgroundColorIsPrimary = true;
  MaterialColor backgroundColor = Colors.primaries.first;
  IconData icon = Icons.category;

  @override
  void dispose() {
    titleController.dispose();
    titleFocus.dispose();
    super.dispose();
  }

  onSelectedIcon(BuildContext context) async {
    IconData icon = await _showIconPicker(context);
    if (icon != null) {
      setState(() => this.icon = icon);
    }
  }

  onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      DataSource.instance.addCategory(
        wallet: widget.walletRef,
        title: titleController.text.trim(),
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        icon: icon,
      );
      Navigator.of(context).pop();
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
        labelText: "#Title",
      ),
      autofocus: true,
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      validator: (title) {
        if (title.trim().isEmpty) {
          return "#Title is required";
        }
        return null;
      },
      onFieldSubmitted: (title) => titleFocus.unfocus(),
    );
  }

  Widget buildIconPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: CircleAvatar(
          backgroundColor: backgroundColor.shade100,
          child: Icon(
            icon,
            color: primaryColor.shade800,
            size: 48,
          ),
          radius: 48,
        ),
        onTap: () => onSelectedIcon(context),
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
            title: Text("#Background is the same color"),
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
        child: Text("#Add"),
        onPressed: () => onSelectedSubmit(context),
      ),
    );
  }

  Future<IconData> _showIconPicker(BuildContext context) async {
    final IconPack iconPack = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("#Select icon pack"),
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
      searchHintText: "#Search",
      noResultsText: "#No results for:",
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
        return "#Material icons";
      case IconPack.materialOutline:
        return "#Outlined Material icons";
      case IconPack.cupertino:
        return "#Cupertino icons";
      case IconPack.fontAwesomeIcons:
        return "#Font Awesome icons";
      case IconPack.lineAwesomeIcons:
        return "#Line Awesome icons";
    }
    return null;
  }
}
