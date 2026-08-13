class CurrentEmergency {
  final String id;
  final String status;
  final String? checkedInAt;
  final String? hospitalName;

  const CurrentEmergency({
    required this.id,
    required this.status,
    this.checkedInAt,
    this.hospitalName,
  });

  factory CurrentEmergency.fromJson(Map<String, dynamic> json) {
    final hospital = json['checked_in_hospital'];

    return CurrentEmergency(
      id: json['id'].toString(),
      status: json['status'].toString(),
      checkedInAt: json['checked_in_at']?.toString(),
      hospitalName: hospital is Map<String, dynamic>
          ? hospital['name']?.toString()
          : null,
    );
  }
}