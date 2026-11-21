enum BudgetLevel { under, warning, reached }

enum BudgetCrossing { none, warning, reached }

BudgetLevel budgetLevel(double spent, double limit) {
  if (limit <= 0) return BudgetLevel.under;
  final ratio = spent / limit;
  if (ratio >= 1) return BudgetLevel.reached;
  if (ratio >= 0.8) return BudgetLevel.warning;
  return BudgetLevel.under;
}

BudgetCrossing budgetCrossing({
  required double previousSpent,
  required double nextSpent,
  required double limit,
}) {
  final before = budgetLevel(previousSpent, limit);
  final after = budgetLevel(nextSpent, limit);
  if (after == BudgetLevel.reached && before != BudgetLevel.reached) {
    return BudgetCrossing.reached;
  }
  if (after == BudgetLevel.warning && before == BudgetLevel.under) {
    return BudgetCrossing.warning;
  }
  return BudgetCrossing.none;
}

bool isDuplicateReference({
  required String? reference,
  required String? existingReference,
  required int? existingId,
  required int? editingId,
}) {
  if (reference == null || reference.trim().isEmpty) return false;
  if (existingReference == null) return false;
  if (existingReference != reference.trim()) return false;
  return existingId != editingId;
}
