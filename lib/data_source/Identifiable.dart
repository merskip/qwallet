import 'package:qwallet/data_source/Identifier.dart';

abstract class Identifiable<T> {
  final Identifier<T> identifier;

  Identifiable(this.identifier);
}
