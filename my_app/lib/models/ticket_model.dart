import 'package:flutter/material.dart';

enum TicketCategory { computer, network, software, other }

enum TicketPriority { low, medium, high, urgent }

enum TicketStatus { open, inProgress, resolved }

class TicketModel {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  static TicketCategory parseCategory(String val) {
    switch (val.toLowerCase()) {
      case 'computer':
        return TicketCategory.computer;
      case 'network':
        return TicketCategory.network;
      case 'software':
        return TicketCategory.software;
      default:
        return TicketCategory.other;
    }
  }

  static String categoryToString(TicketCategory cat) {
    switch (cat) {
      case TicketCategory.computer:
        return 'computer';
      case TicketCategory.network:
        return 'network';
      case TicketCategory.software:
        return 'software';
      case TicketCategory.other:
        return 'other';
    }
  }

  static TicketPriority parsePriority(String val) {
    switch (val.toLowerCase()) {
      case 'low':
        return TicketPriority.low;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      default:
        return TicketPriority.medium;
    }
  }

  static String priorityToString(TicketPriority pri) {
    switch (pri) {
      case TicketPriority.low:
        return 'low';
      case TicketPriority.medium:
        return 'medium';
      case TicketPriority.high:
        return 'high';
      case TicketPriority.urgent:
        return 'urgent';
    }
  }

  static TicketStatus parseStatus(String val) {
    switch (val.toLowerCase().replaceAll(' ', '_')) {
      case 'in_progress':
      case 'inprogress':
        return TicketStatus.inProgress;
      case 'resolved':
      case 'closed':
        return TicketStatus.resolved;
      default:
        return TicketStatus.open;
    }
  }

  static String statusToString(TicketStatus st) {
    switch (st) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
    }
  }

  String get categoryLabel {
    switch (category) {
      case TicketCategory.computer:
        return 'คอมพิวเตอร์ / อุปกรณ์';
      case TicketCategory.network:
        return 'ระบบเครือข่าย / เน็ต';
      case TicketCategory.software:
        return 'ซอฟต์แวร์ / โปรแกรม';
      case TicketCategory.other:
        return 'ปัญหาอื่นๆ';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TicketCategory.computer:
        return Icons.computer_rounded;
      case TicketCategory.network:
        return Icons.wifi_rounded;
      case TicketCategory.software:
        return Icons.apps_rounded;
      case TicketCategory.other:
        return Icons.build_circle_rounded;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return 'ต่ำ';
      case TicketPriority.medium:
        return 'ปานกลาง';
      case TicketPriority.high:
        return 'สูง';
      case TicketPriority.urgent:
        return 'เร่งด่วนที่สุด';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF10B981);
      case TicketPriority.medium:
        return const Color(0xFFF59E0B);
      case TicketPriority.high:
        return const Color(0xFFF97316);
      case TicketPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'รอดำเนินการ';
      case TicketStatus.inProgress:
        return 'กำลังแก้ไข';
      case TicketStatus.resolved:
        return 'แก้ไขเรียบร้อย';
    }
  }

  Color get statusColor {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF3B82F6);
      case TicketStatus.inProgress:
        return const Color(0xFF8B5CF6);
      case TicketStatus.resolved:
        return const Color(0xFF10B981);
    }
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      userName: json['requester_name'] ?? json['user_name'] ?? json['name'] ?? 'ผู้ใช้งาน',
      userEmail: json['requester_email'] ?? json['user_email'] ?? json['email'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: parseCategory(json['category'] ?? 'other'),
      priority: parsePriority(json['priority'] ?? 'medium'),
      status: parseStatus(json['status'] ?? 'open'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'requester_name': userName,
      'requester_email': userEmail,
      'title': title,
      'description': description,
      'category': categoryToString(category),
      'priority': priorityToString(priority),
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TicketModel copyWith({
    int? id,
    int? userId,
    String? userName,
    String? userEmail,
    String? title,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
