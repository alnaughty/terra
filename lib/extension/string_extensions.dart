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

extension Currency on String {
  static final regExp = RegExp(r"^\s*-?[0-9]{1,10}\s*$");
  bool isValidInt() => regExp.hasMatch(this);
}

extension ToURI on String {
  Uri get toUri => Uri.parse(this);
}
