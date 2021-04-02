import 'package:qwallet/datasource/Identifier.dart';

abstract class Identifiable<T> {
  final Identifier<T> identifier;

  Identifiable(this.identifier);
}
