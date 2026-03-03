class HelplineContactEntity {
  final String name;
  final String number;

  const HelplineContactEntity({
    required this.name,
    required this.number,
  });
}

class HelplineNumbersEntity {
  final String officeNumber;
  final List<HelplineContactEntity> contacts;
  final DateTime? updatedAt;

  const HelplineNumbersEntity({
    required this.officeNumber,
    required this.contacts,
    this.updatedAt,
  });
}
