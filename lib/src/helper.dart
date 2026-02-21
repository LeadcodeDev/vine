bool isEmailSimd(String input) {
  final atIndex = input.indexOf('@');
  if (atIndex == -1 || atIndex == 0 || atIndex == input.length - 1) {
    return false;
  }

  final domainPart = input.substring(atIndex + 1);
  if (domainPart.isEmpty || !domainPart.contains('.')) {
    return false;
  }

  return !input.contains(' ');
}
