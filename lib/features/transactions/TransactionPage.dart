import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/CustomField.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/FirebaseFileStorageProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseTransaction.dart';
import 'package:qwallet/features/camera/TakePhotoPage.dart';
import 'package:qwallet/features/files/FilePreviewPage.dart';
import 'package:qwallet/features/files/FilesCarousel.dart';
import 'package:qwallet/features/files/UniversalFile.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/EnterMoneyDialog.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';

import '../../AppLocalizations.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';

class TransactionPage extends StatefulWidget {
  final Wallet wallet;
  final Transaction transaction;

  const TransactionPage({
    Key? key,
    required this.wallet,
    required this.transaction,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState(transaction);
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController titleController;
  final amountController = AmountEditingController();

  late Category? _selectedCategory;
  late TransactionType _selectedType;
  late bool _excludedFromDailyStatistics;

  final customFieldsValues = <String, dynamic>{};

  _TransactionPageState(Transaction transaction)
      : titleController = TextEditingController(text: transaction.title),
        super();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text(
          AppLocalizations.of(context).transactionDetailsRemoveConfirmation),
      content: Text(AppLocalizations.of(context)
          .transactionDetailsRemoveConfirmationContent),
      isDestructive: true,
      onConfirm: () async {
        if (widget.transaction is FirebaseTransaction) {
          final transaction = widget.transaction as FirebaseTransaction;
          transaction.attachedFiles.forEach((fileUri) async {
            final file =
                await FirebaseFileStorageProvider().getUniversalFile(fileUri);
            file.delete();
          });
        }

        await SharedProviders.transactionsProvider.removeTransaction(
          walletId: widget.wallet.identifier,
          transaction: widget.transaction,
        );
        Navigator.of(context).popUntil((route) {
          return !(route.settings.name?.contains("transaction") ?? true);
        });
      },
    ).show(context);
  }

  void onSelectedSaveCategory(BuildContext context) {
    SharedProviders.transactionsProvider.updateTransaction(
      wallet: widget.wallet,
      transaction: widget.transaction,
      type: widget.transaction.type,
      category: _selectedCategory,
      title: widget.transaction.title,
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      customFields: widget.transaction.customFields,
    );
  }

  void onSelectedSaveType(BuildContext context) {
    SharedProviders.transactionsProvider.updateTransaction(
      wallet: widget.wallet,
      transaction: widget.transaction,
      type: _selectedType,
      category: widget.transaction.category,
      title: widget.transaction.title,
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      customFields: widget.transaction.customFields,
    );
  }

  void onSelectedSaveTitle(BuildContext context) {
    SharedProviders.transactionsProvider.updateTransaction(
      wallet: widget.wallet,
      transaction: widget.transaction,
      type: widget.transaction.type,
      category: widget.transaction.category,
      title: titleController.text.trim().nullIfEmpty(),
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      customFields: widget.transaction.customFields,
    );
  }

  void onSelectedEditAmount(BuildContext context) async {
    final amount = Money(widget.transaction.amount, widget.wallet.currency);
    final newAmount = await showDialog(
      context: context,
      builder: (context) => EnterMoneyDialog(
        initialMoney: amount,
        currency: amount.currency,
      ),
    );
    if (newAmount != null) {
      SharedProviders.transactionsProvider.updateTransaction(
        wallet: widget.wallet,
        transaction: widget.transaction,
        type: widget.transaction.type,
        category: widget.transaction.category,
        title: widget.transaction.title,
        amount: newAmount.amount,
        date: widget.transaction.date,
        customFields: widget.transaction.customFields,
      );
    }
  }

  void onSelectedEditDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.transaction.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );
      SharedProviders.transactionsProvider.updateTransaction(
        wallet: widget.wallet,
        transaction: widget.transaction,
        type: widget.transaction.type,
        category: widget.transaction.category,
        title: widget.transaction.title,
        amount: widget.transaction.amount,
        date: dateTime,
        customFields: widget.transaction.customFields,
      );
    }
  }

  void onSelectedAttachedFile(BuildContext context, UniversalFile file) async {
    FilePreviewPage.show(
      context,
      file,
      onDelete: (context, file) => onSelectedDeleteAttachedFile(context, file),
    );
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
      _addAttachFiles([photoFile]);
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
      _addAttachFiles(files);
    }
  }

  void _addAttachFiles(List<LocalUniversalFile> files) async {
    final provider = FirebaseFileStorageProvider();
    final uploadedFiles = await Future.wait(files.map((file) =>
        provider.uploadFile(
            widget.wallet.identifier, widget.transaction.identifier, file)));

    for (final file in uploadedFiles) {
      await SharedProviders.transactionsProvider.addTransactionAttachedFile(
        walletId: widget.wallet.identifier,
        transaction: widget.transaction.identifier,
        attachedFile: file.uri,
      );
    }
  }

  void onSelectedDeleteAttachedFile(
    BuildContext context,
    UniversalFile file,
  ) async {
    SharedProviders.transactionsProvider.removeTransactionAttachedFile(
      walletId: widget.wallet.identifier,
      transaction: widget.transaction.identifier,
      attachedFile: file.uri,
    );
    file.delete();
  }

  void onChangedCustomFieldValue(
    BuildContext context,
    CustomField customField,
    dynamic value,
  ) {
    var customFields = widget.transaction.customFields ?? {};
    customFields[customField.key] = value;
    SharedProviders.transactionsProvider.updateTransaction(
      wallet: widget.wallet,
      transaction: widget.transaction,
      type: widget.transaction.type,
      category: widget.transaction.category,
      title: widget.transaction.title,
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      customFields: customFields,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction.title ??
              (widget.transaction.type == TransactionType.expense
                  ? AppLocalizations.of(context).transactionTypeExpense
                  : AppLocalizations.of(context).transactionTypeIncome),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          buildWallet(context, widget.wallet),
          buildAttachedFilesCarousel(context),
          buildCategory(context),
          buildType(context),
          buildTitle(context),
          buildAmount(context, widget.wallet),
          buildDate(context),
          if (widget.transaction is FirebaseTransaction)
            buildExcludedFromDailyStatistics(
                context, widget.transaction as FirebaseTransaction),
          buildCustomFields(context),
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: DetailsItemTile(
          title: Text(AppLocalizations.of(context).transactionDetailsWallet),
          value: Text(wallet.name + " (${wallet.balance.formatted})"),
        ),
      ),
    );
  }

  Widget buildAttachedFilesCarousel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SimpleStreamWidget.fromFuture(
        future: getAttachedFiles(),
        builder: (context, List<UniversalFile> files) {
          return FilesCarousel(
            files: files,
            onPressedFile: (context, file) =>
                onSelectedAttachedFile(context, file),
            onPressedAdd: () => onSelectedAddAttachedFile(context),
          );
        },
      ),
    );
  }

  Future<List<UniversalFile>> getAttachedFiles() async {
    final provider = FirebaseFileStorageProvider();
    return Future.wait(widget.transaction.attachedFiles.map((fileUri) {
      return provider.getUniversalFile(fileUri);
    }));
  }

  Widget buildCategory(BuildContext context) {
    final category = widget.transaction.category;
    if (category != null) {
      return buildCategoryDetailsItem(
        context,
        leading: CategoryIcon(category, size: 20),
        value: Text(category.titleText),
        category: category,
      );
    } else {
      return buildCategoryDetailsItem(
        context,
        leading: CategoryIcon(null, size: 20),
        value: Text(
          AppLocalizations.of(context).transactionDetailsCategoryEmpty,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        category: null,
      );
    }
  }

  Widget buildCategoryDetailsItem(
    BuildContext context, {
    required Widget leading,
    required Widget value,
    Category? category,
  }) {
    return DetailsItemTile(
      leading: leading,
      title: Text(AppLocalizations.of(context).transactionDetailsCategory),
      value: value,
      editingBegin: () => _selectedCategory = category,
      editingContent: widget.wallet.categories.isNotEmpty
          ? (context) => buildCategoryEditing(context)
          : null,
      editingSave: () => onSelectedSaveCategory(context),
    );
  }

  Widget buildCategoryEditing(BuildContext context) {
    return CategoryPicker(
      title: Text(AppLocalizations.of(context).transactionDetailsCategory),
      selectedCategory: _selectedCategory,
      categories: widget.wallet.categories,
      onChangeCategory: (category) {
        final effectiveCategory =
            category != _selectedCategory ? category : null;
        setState(() => _selectedCategory = effectiveCategory);
      },
    );
  }

  Widget buildType(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsType),
      value: Text(widget.transaction.type == TransactionType.expense
          ? AppLocalizations.of(context).transactionTypeExpense
          : AppLocalizations.of(context).transactionTypeIncome),
      editingBegin: () => _selectedType = widget.transaction.type,
      editingContent: (context) => buildTypeEditing(context),
      editingSave: () => onSelectedSaveType(context),
    );
  }

  Widget buildTypeEditing(BuildContext context) {
    final buildTypeButton = (TransactionType type) => TransactionTypeButton(
          type: type,
          isSelected: _selectedType == type,
          onPressed: () => setState(() => _selectedType = type),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).transactionDetailsType),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildTypeButton(TransactionType.expense),
            buildTypeButton(TransactionType.income),
          ],
        ),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    final title = widget.transaction.title;
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsTitle),
      value: title != null
          ? Text(title)
          : Text(AppLocalizations.of(context).transactionDetailsTitleEmpty,
              style: TextStyle(fontStyle: FontStyle.italic)),
      editingContent: (context) => buildTitleEditing(context),
      editingSave: () => onSelectedSaveTitle(context),
    );
  }

  Widget buildTitleEditing(BuildContext context) {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).transactionDetailsTitle,
      ),
      autofocus: true,
      maxLength: 50,
    );
  }

  Widget buildAmount(BuildContext context, Wallet wallet) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsAmount),
      value: Text(
          Money(widget.transaction.amount, widget.wallet.currency).formatted),
      onEdit: (context) => onSelectedEditAmount(context),
    );
  }

  Widget buildDate(BuildContext context) {
    final format = DateFormat("d MMMM yyyy");
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsDate),
      value: Text(format.format(widget.transaction.date)),
      onEdit: (context) => onSelectedEditDate(context),
    );
  }

  Widget buildExcludedFromDailyStatistics(
    BuildContext context,
    FirebaseTransaction firebaseTransaction,
  ) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context)
          .transactionDetailsExcludedFromDailyStatistics),
      value: Text(widget.transaction.excludedFromDailyStatistics
          ? AppLocalizations.of(context)
              .transactionDetailsExcludedFromDailyStatisticsExcluded
          : AppLocalizations.of(context)
              .transactionDetailsExcludedFromDailyStatisticsIncluded),
      editingBegin: () {
        _excludedFromDailyStatistics =
            widget.transaction.excludedFromDailyStatistics;
      },
      editingContent: (context) => CheckboxListTile(
        title: Text("Include to daily statistics"),
        value: !_excludedFromDailyStatistics,
        onChanged: (value) => setState(() {
          _excludedFromDailyStatistics = !(value ?? true);
        }),
      ),
      editingSave: () {
        SharedProviders.firebaseTransactionsProvider.updateTransactionExtra(
          walletId: widget.wallet.identifier,
          transaction: widget.transaction,
          excludedFromDailyStatistics: _excludedFromDailyStatistics,
        );
      },
    );
  }

  Widget buildCustomFields(BuildContext context) {
    return SimpleStreamWidget(
      stream: SharedProviders.transactionsProvider.getCustomFields(
        walletId: widget.wallet.identifier,
        transactionId: widget.transaction.identifier,
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
    return DetailsItemTile(
      title: Text(customField.localizedTitle),
      value: Icon(
        customField.initialValue
            ? Icons.check_box
            : Icons.check_box_outline_blank,
        color: customField.initialValue ? Theme.of(context).primaryColor : null,
      ),
      editingBegin: () {
        setState(() {
          customFieldsValues[customField.key] = customField.initialValue;
        });
      },
      editingContent: (context) => CheckboxListTile(
        title: Text(customField.localizedTitle),
        value: value,
        onChanged: (value) {
          setState(() {
            customFieldsValues[customField.key] = value;
          });
        },
      ),
      editingSave: () {
        onChangedCustomFieldValue(context, customField, value);
      },
    );
  }

  Widget buildCustomFieldDropdownList(
    BuildContext context,
    CustomField customField,
    String? value,
  ) {
    return DetailsItemTile(
      title: Text(customField.localizedTitle),
      value: Text(customField.initialValue ?? "-"),
      editingBegin: () {
        setState(() {
          customFieldsValues[customField.key] = customField.initialValue;
        });
      },
      editingContent: (context) => ListTile(
        title: Text(customField.localizedTitle),
        trailing: DropdownButton(
          value: value,
          items: [
            ...customField.dropdownListValues!.map(
              (value) => DropdownMenuItem(
                child: Text(value),
                value: value,
              ),
            )
          ],
          onChanged: (value) {
            setState(() {
              customFieldsValues[customField.key] = value;
            });
          },
        ),
      ),
      editingSave: () {
        onChangedCustomFieldValue(context, customField, value);
      },
    );
  }
}
