import 'package:hive/hive.dart';
part 'contact_model.g.dart';

@HiveType(typeId: 0)
class Contacts {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int number;
  Contacts({required this.name, required this.number});
}
