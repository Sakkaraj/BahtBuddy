class SlipFieldScore {
  const SlipFieldScore({
    required this.amount,
    required this.date,
    required this.recipient,
    required this.reference,
  });

  final bool amount;
  final bool date;
  final bool recipient;
  final bool reference;

  bool get complete => amount && date && recipient && reference;

  int get hits =>
      (amount ? 1 : 0) +
      (date ? 1 : 0) +
      (recipient ? 1 : 0) +
      (reference ? 1 : 0);
}

SlipFieldScore scoreSlip({
  required double? amount,
  required DateTime? date,
  required String? recipient,
  required String? reference,
  required double expectedAmount,
  required DateTime expectedDate,
  required String expectedRecipient,
  required String expectedReference,
}) {
  return SlipFieldScore(
    amount: amount != null && (amount - expectedAmount).abs() < 0.001,
    date: date != null &&
        date.year == expectedDate.year &&
        date.month == expectedDate.month &&
        date.day == expectedDate.day &&
        date.hour == expectedDate.hour &&
        date.minute == expectedDate.minute,
    recipient: recipient?.trim() == expectedRecipient,
    reference: reference == expectedReference,
  );
}
