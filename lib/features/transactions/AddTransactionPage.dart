import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/CustomField.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/FirebaseFileStorageProvider.dart';
import 'package:qwallet/features/files/FilePreviewPage.dart';
import 'package:qwallet/features/files/FilesCarousel.dart';
import 'package:qwallet/features/files/UniversalFile.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SelectWalletDialog.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';
import 'package:qwallet/widget/VectorImage.dart';

import '../../AppLocalizations.dart';
import '../../router.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';
import '../camera/TakePhotoPage.dart';

final _formKey = GlobalKey<_AddTransactionFormState>();

class AddTransactionPage extends StatelessWidget {
  final Wallet initialWallet;
  final double? initialAmount;

  AddTransactionPage({
    Key? key,
    required this.initialWallet,
    this.initialAmount,
  }) : super(key: key);

  void onSelectedAddSeriesTransactions(BuildContext context) {
    final currentState = _formKey.currentState;
    if (currentState == null) return;

    final type = currentState.type;
    if (type == TransactionType.income) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            AppLocalizations.of(context).addSeriesTransactionsExpensesOnly),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    final wallet = currentState.wallet;
    final amount = currentState.amountController.value?.amount;
    final date = currentState.date;
    router.pop(context, null);
    router.navigateTo(
        context,
        "/wallet/${wallet.identifier}/addSeriesTransactions"
        "?initialTotalAmount=$amount"
        "&initialDate=${date.toIso8601String()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addTransaction),
        actions: [
          IconButton(
            icon: VectorImage(
              "assets/ic-add-series-transactions.svg",
            ),
            tooltip: AppLocalizations.of(context).addSeriesTransactionsTooltip,
            onPressed: () => onSelectedAddSeriesTransactions(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddTransactionForm(
            key: _formKey,
            initialWallet: initialWallet,
            initialAmount: initialAmount?.abs(),
            initialTransactionType: (initialAmount ?? 0) <= 0
                ? TransactionType.expense
                : TransactionType.income,
          ),
        ),
      ),
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final Wallet initialWallet;
  final double? initialAmount;
  final TransactionType? initialTransactionType;

  const _AddTransactionForm({
    Key? key,
    required this.initialWallet,
    this.initialAmount,
    this.initialTransactionType,
  }) : super(key: key);

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState(
        initialWallet,
        initialTransactionType ?? TransactionType.expense,
      );
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  Wallet wallet;

  TransactionType type;

  final amountController = AmountEditingController();

  Category? category;

  final titleFocus = FocusNode();
  final titleController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date = DateTime.now();

  final attachedFiles = <LocalUniversalFile>[];

  final customFieldsValues = <String, dynamic>{};

  var _isSubmitting = false;

  _AddTransactionFormState(this.wallet, this.type);

  @override
  void initState() {
    _configureDate();
    amountController.addListener(() => setState(() {
          // Nothing, just needed for refresh balance after, see #62
        }));
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    titleFocus.dispose();
    titleController.dispose();
    dateFocus.dispose();
    dateController.dispose();
    super.dispose();
  }

  _configureDate() {
    dateController.text = getFormattedDate(date);

    dateFocus.addListener(() async {
      if (dateFocus.hasFocus) {
        dateFocus.unfocus();
        final date = await showDatePicker(
          context: context,
          initialDate: this.date,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          // Adding local now time
          final now = DateTime.now();
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            now.hour,
            now.minute,
            now.second,
          );
          setState(() {
            dateController.text = getFormattedDate(dateTime);
            this.date = dateTime;
          });
        }
      }
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat("d MMMM yyyy").format(date);
  }

  onSelectedWallet(BuildContext context) async {
    final wallets =
        await SharedProviders.orderedWalletsProvider.getOrderedWallets().first;
    final selectedWallet = await showDialog(
      context: context,
      builder: (context) => SelectWalletDialog(
        title: AppLocalizations.of(context).addTransactionSelectWallet,
        wallets: wallets,
        selectedWallet: this.wallet,
      ),
    ) as Wallet?;
    if (selectedWallet != null) {
      setState(() => this.wallet = selectedWallet);
    }
  }

  void onSelectedAddAttachedFile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(Icons.photo_camera),
            title: Text(AppLocalizations.of(context).attachedFileTakePhoto),
            onTap: () => onSelectedAttachedFilesTakePhoto(context),
          ),
          ListTile(
            leading: Icon(Icons.attach_file),
            title: Text(AppLocalizations.of(context).attachedFileSelectFiles),
            onTap: () => onSelectedAttachedFileSelectFile(context),
          ),
        ],
      ),
    );
  }

  void onSelectedAttachedFilesTakePhoto(BuildContext context) async {
    Navigator.of(context).pop();
    final photoFile = await pushPage(
      context,
      builder: (context) => TakePhotoPage(),
    ) as LocalUniversalFile?;
    if (photoFile != null) {
      setState(() {
        attachedFiles.add(photoFile);
      });
    }
  }

  void onSelectedAttachedFileSelectFile(BuildContext context) async {
    Navigator.of(context).pop();

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      final files = result.paths
          .filterNonNull()
          .map((p) => LocalUniversalFile(File(p)))
          .toList();
      setState(() {
        attachedFiles.addAll(files);
      });
    }
  }

  void onSelectedDeleteFile(
      BuildContext context, LocalUniversalFile file) async {
    await file.localFile.delete();
    setState(() {
      attachedFiles.remove(file);
    });
  }

  onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        final transactionId =
            await SharedProviders.transactionsProvider.addTransaction(
          walletId: wallet.identifier,
          type: type,
          category: category,
          title: titleController.text.trim().nullIfEmpty(),
          amount: amountController.value!.amount,
          date: date,
          customFields: customFieldsValues,
        );

        if (attachedFiles.isNotEmpty) {
          final uploadedFiles = await Future.wait(
            attachedFiles.map((file) => FirebaseFileStorageProvider()
                .uploadFile(wallet.identifier, transactionId, file)),
          );

          for (final file in uploadedFiles) {
            await SharedProviders.transactionsProvider
                .addTransactionAttachedFile(
              walletId: wallet.identifier,
              transaction: transactionId,
              attachedFile: file.uri,
            );
          }
        }

        router.pop(context);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Column(children: [
          buildWallet(context),
          SizedBox(height: 8),
          buildType(context),
          SizedBox(height: 16),
          buildAmount(context),
          SizedBox(height: 16),
          if (wallet.categories.isNotEmpty)
            buildCategoryPicker(context, wallet.categories),
          SizedBox(height: 16),
          buildTitle(context),
          SizedBox(height: 16),
          buildDate(context),
          SizedBox(height: 16),
          buildAttachedImages(context),
          SizedBox(height: 16),
          buildCustomFields(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: buildSubmitButton(context),
          )
        ]),
      ),
    );
  }

  Widget buildType(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TransactionTypeButton(
          type: TransactionType.expense,
          isSelected: type == TransactionType.expense,
          onPressed: () => setState(() => type = TransactionType.expense),
        ),
        TransactionTypeButton(
          type: TransactionType.income,
          isSelected: type == TransactionType.income,
          onPressed: () => setState(() => type = TransactionType.income),
        ),
      ],
    );
  }

  Widget buildWallet(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(wallet.name),
        trailing: Text(wallet.balance.formatted),
        onTap: () => onSelectedWallet(context),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    final initialMoney = widget.initialAmount != null
        ? Money(widget.initialAmount!, widget.initialWallet.currency)
        : null;
    return AmountFormField(
      initialMoney: initialMoney,
      currency: widget.initialWallet.currency,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionAmount,
        helperText: getBalanceAfterTransactionText(),
      ),
      controller: amountController,
      validator: (amount) {
        if (amount == null)
          return AppLocalizations.of(context).addTransactionAmountErrorIsEmpty;
        if (amount.amount <= 0)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorZeroOrNegative;
        return null;
      },
    );
  }

  String getBalanceAfterTransactionText() {
    final amount =
        amountController.value?.amount ?? widget.initialAmount ?? 0.0;
    final balanceAfter = type == TransactionType.expense
        ? wallet.balance.amount - amount
        : wallet.balance.amount + amount;
    final balanceAfterMoney = Money(balanceAfter, wallet.currency);
    return AppLocalizations.of(context)
        .addTransactionBalanceAfter(balanceAfterMoney);
  }

  Widget buildCategoryPicker(BuildContext context, List<Category> categories) {
    return CategoryPicker(
      categories: categories,
      selectedCategory: category,
      title: Text(AppLocalizations.of(context).addTransactionCategory),
      onChangeCategory: (category) {
        FocusScope.of(context).unfocus();
        setState(() {
          this.category = (this.category != category ? category : null);
        });
      },
    );
  }

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      controller: titleController,
      focusNode: titleFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionTitle,
        isDense: true,
      ),
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => titleFocus.unfocus(),
    );
  }

  Widget buildDate(BuildContext context) {
    return TextFormField(
      controller: dateController,
      focusNode: dateFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionDate,
        suffixIcon: Icon(Icons.date_range),
        isDense: true,
      ),
      textInputAction: TextInputAction.next,
      readOnly: true,
    );
  }

  Widget buildAttachedImages(BuildContext context) {
    return FilesCarousel(
      files: attachedFiles,
      onPressedAdd: () => onSelectedAddAttachedFile(context),
      onPressedFile: (context, file) => FilePreviewPage.show(
        context,
        file,
        onDelete: (context, file) =>
            onSelectedDeleteFile(context, file as LocalUniversalFile),
      ),
    );
  }

  Widget buildCustomFields(BuildContext context) {
    return SimpleStreamWidget(
      stream: SharedProviders.transactionsProvider.getCustomFields(
        walletId: wallet.identifier,
        transactionId: null,
      ),
      builder: (context, List<CustomField> customFields) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...customFields.map((customField) {
              final value = customFieldsValues.containsKey(customField.key)
                  ? customFieldsValues[customField.key]
                  : customField.initialValue;
              switch (customField.type) {
                case CustomFieldType.checkbox:
                  return buildCustomFieldCheckbox(context, customField, value);
                case CustomFieldType.dropdownList:
                  return buildCustomFieldDropdownList(
                      context, customField, value);
              }
            })
          ],
        );
      },
    );
  }

  Widget buildCustomFieldCheckbox(
    BuildContext context,
    CustomField customField,
    bool value,
  ) {
    return CheckboxListTile(
      title: Text(customField.localizedTitle),
      value: value,
      onChanged: (value) {
        setState(() {
          customFieldsValues[customField.key] = value;
        });
      },
    );
  }

  Widget buildCustomFieldDropdownList(
    BuildContext context,
    CustomField customField,
    String? value,
  ) {
    return ListTile(
      title: Text(customField.localizedTitle),
      trailing: DropdownButton(
        value: value,
        items: [
          DropdownMenuItem(
            child: Text("-"),
            value: "<null>",
          ),
          ...customField.dropdownListValues!.map(
            (value) => DropdownMenuItem(
              child: Text(value),
              value: value,
            ),
          )
        ],
        onChanged: (value) {
          setState(() {
            customFieldsValues[customField.key] =
                value != "<null>" ? value : null;
          });
        },
      ),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: _isSubmitting
          ? CircularProgressIndicator()
          : Text(AppLocalizations.of(context).addTransactionSubmit),
      onPressed: !_isSubmitting ? () => onSelectedSubmit(context) : null,
    );
  }
}
