import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
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
          child: _AddCategoryForm(),
        ),
      ),
    );
  }
}

class _AddCategoryForm extends StatefulWidget {
  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<_AddCategoryForm> {
  final _formKey = GlobalKey<_AddCategoryFormState>();

  final titleController = TextEditingController();
  final titleFocus = FocusNode();

  MaterialColor primaryColor = Colors.primaries.first;
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildTitleField(context),
        buildIconPreview(context),
        buildColorPicker(context),
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
      onFieldSubmitted: (title) => titleFocus.unfocus(),
    );
  }

  Widget buildIconPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: CircleAvatar(
          backgroundColor: primaryColor?.shade100 ?? Colors.transparent,
          child: Icon(
            icon,
            color: primaryColor?.shade800 ?? Colors.transparent,
            size: 48,
          ),
          radius: 48,
        ),
        onTap: () => onSelectedIcon(context),
      ),
    );
  }

  Widget buildColorPicker(BuildContext context) {
    return ColorPicker(
      colors: Colors.primaries,
      selectedColor: primaryColor,
      onChangeColor: (color) => setState(() => this.primaryColor = color),
    );
  }

  Widget buildSubmit(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PrimaryButton(
        child: Text("#Add"),
        onPressed: () {},
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
