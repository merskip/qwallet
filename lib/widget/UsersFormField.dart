import 'package:flutter/material.dart';
import 'package:qwallet/model/user.dart';

class UsersFormField extends FormField<List<User>> {
  final UsersEditingController controller;
  final InputDecoration decoration;

  UsersFormField({
    required List<User> initialValue,
    required this.controller,
    required this.decoration,
    FormFieldValidator<List<User>>? validator,
  }) : super(
          builder: (FormFieldState<List<User>> state) => Builder(
            builder: (context) => buildUsersInput(context, decoration, state),
          ),
          initialValue: initialValue,
          validator: validator,
        );

  @override
  FormFieldState<List<User>> createState() => _UsersFormFieldState(controller);

  static Widget buildUsersInput(BuildContext context,
      InputDecoration decoration, FormFieldState<List<User>> state) {
    return InputDecorator(
      decoration: decoration.copyWith(
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        errorText: state.errorText,
      ),
      child: Wrap(
        children: [
          ...?state.value?.map((user) => buildUserChip(context, user)),
        ],
        spacing: 4,
        runSpacing: 4,
      ),
    );
  }

  static Widget buildUserChip(BuildContext context, User user) {
    return Chip(
      avatar: buildAvatar(context, user),
      label: Text(user.getCommonName(context)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget buildAvatar(BuildContext context, User user) {
    if (user.avatarUrl != null)
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatarUrl!),
        backgroundColor: Colors.transparent,
      );
    else if (user.displayName != null)
      return Icon(Icons.person, color: Colors.black54);
    else
      return Icon(Icons.alternate_email, color: Colors.black54);
  }
}

class UsersEditingController extends ValueNotifier<List<User>?> {
  UsersEditingController() : super(null);
}

class _UsersFormFieldState extends FormFieldState<List<User>> {
  final UsersEditingController controller;

  _UsersFormFieldState(this.controller);

  @override
  void initState() {
    controller.addListener(() => this.didChange(controller.value));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
