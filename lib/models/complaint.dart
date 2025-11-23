class Complaint {
  final int complaintId;
  final String jobId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String complaintDate;
  final String complaintStatus;
  final String? closedDate;
  final String priority;
  final String complaintDescription;
  final String? notes;
  final String? typeOfService;
  final String? typeOfDevice;
  final String? brand;

  Complaint({
    required this.complaintId,
    required this.jobId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.complaintDate,
    required this.complaintStatus,
    this.closedDate,
    required this.priority,
    required this.complaintDescription,
    this.notes,
    this.typeOfService,
    this.typeOfDevice,
    this.brand,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      complaintId: int.parse(json['complaint_id'].toString()),
      jobId: json['job_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      complaintDate: json['complaint_date'] ?? '',
      complaintStatus: json['complaint_status'] ?? 'pending',
      closedDate: json['closed_date'],
      priority: json['priority'] ?? 'low',
      complaintDescription: json['complaint_description'] ?? '',
      notes: json['notes'],
      typeOfService: json['type_of_service'],
      typeOfDevice: json['type_of_device'],
      brand: json['brand'],
    );
  }
}
