import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/widget/ColorPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class EditCategoryPage extends StatelessWidget {
  final Reference<Category> categoryRef;

  const EditCategoryPage({Key key, this.categoryRef}) : super(key: key);

  onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text("#Remove category?"),
      content: Text("#Are you sure that you want remove this category? This operation cannot be undone."),
      isDestructive: true,
      onConfirm: () {
        DataSource.instance.removeCategory(category: categoryRef);
        Navigator.of(context)
            .popUntil((route) => route.settings.name?.endsWith("/categories") ?? false);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Edit category"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SimpleStreamWidget(
            stream: DataSource.instance.getCategory(category: categoryRef),
            builder: (context, category) =>
                _EditCategoryForm(category: category),
          ),
        ),
      ),
    );
  }
}

class _EditCategoryForm extends StatefulWidget {
  final Category category;

  const _EditCategoryForm({Key key, this.category}) : super(key: key);

  @override
  _EditCategoryFormState createState() => _EditCategoryFormState(category);
}

class _EditCategoryFormState extends State<_EditCategoryForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController;
  final titleFocus = FocusNode();

  MaterialColor primaryColor;
  bool backgroundColorIsPrimary;
  MaterialColor backgroundColor;
  IconData icon;

  _EditCategoryFormState(Category category)
      : titleController = TextEditingController(text: category.title),
        primaryColor = _findMaterialColor(category.primaryColor, 800),
        backgroundColor = _findMaterialColor(category.backgroundColor, 100),
        icon = category.icon {
    backgroundColorIsPrimary = (primaryColor == backgroundColor);
  }

  static MaterialColor _findMaterialColor(Color color, int shade) =>
      Colors.primaries.firstWhere(
        (materialColor) => materialColor[shade] == color,
        orElse: () => null,
      );

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
      DataSource.instance.updateCategory(
        category: widget.category.reference,
        title: titleController.text.trim(),
        primaryColor: primaryColor.shade800,
        backgroundColor: backgroundColor.shade100,
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
          backgroundColor:
              backgroundColor?.shade100 ?? widget.category.backgroundColor,
          child: Icon(
            icon,
            color: primaryColor?.shade800 ?? widget.category.primaryColor,
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
        child: Text("#Save changes"),
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
