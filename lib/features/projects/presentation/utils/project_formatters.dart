String formatProjectDate(DateTime? date) {
  if (date == null) {
    return 'Not set';
  }

  return '${date.month}/${date.day}/${date.year}';
}
