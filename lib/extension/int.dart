extension URGENCY on int {
  String toUrgency() {
    switch (this) {
      case 1:
        return "Not urgent";
      case 2:
        return "Mild urgency";
      case 3:
        return "High priority";
      default:
        return "";
    }
  }
}

extension EXT on int {
  String applicationStatusFormat() {
    switch (this) {
      case 1:
        return "Approved";
      case 2:
        return "Completed";
      case 3:
        return "Declined";
      case 4:
        return "Cancelled";
      default:
        return "Pending";
    }
  }
}
