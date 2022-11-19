extension EmailChecker on String {
  static final RegExp regExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  bool isValidEmail() {
    return regExp.hasMatch(this);
  }
}

extension PhoneChecker on String {
  static final RegExp regExp = RegExp(r"^(09|\+639)\d{9}$");
  bool isValidPhone() {
    return regExp.hasMatch(this);
  }
}
