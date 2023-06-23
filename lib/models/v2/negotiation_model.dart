class NegotiationModel {
  final int id;
  final int negotiatorId;
  final double price;
  final bool employerApproved;
  final bool jobseekerApproved;
  final DateTime createdAt;

  const NegotiationModel({
    required this.id,
    required this.negotiatorId,
    required this.createdAt,
    required this.price,
    required this.jobseekerApproved,
    required this.employerApproved,
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) =>
      NegotiationModel(
        id: json['id'],
        negotiatorId: json['user_id'],
        createdAt: DateTime.parse(json['created_at']),
        price: json['price'] == null
            ? 0.0
            : double.parse(json['price'].toString()),
        jobseekerApproved: json['jobseeker_status'] == 1,
        employerApproved: json['employer_status'] == 1,
      );
}
