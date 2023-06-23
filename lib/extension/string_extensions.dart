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
  static final regExp2 = RegExp(
    r"/(\d)(?=(\d{3})+(?!\d))/",
  );
  bool isValidInt() => regExp.hasMatch(this);
  bool isValidMoney() => regExp2.hasMatch(this);
}

extension ToURI on String {
  Uri get toUri => Uri.parse(this);
}

extension CapitalizeFirstLetter on String {
  String capitalizeWords() {
    List<String> words = split(" ");
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      words[i] = "${word[0].toUpperCase()}${word.substring(1)}";
    }
    return words.join(" ");
  }
}

extension TOINT on String {
  int toInt() => int.parse(this);
}
