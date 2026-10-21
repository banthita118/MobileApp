import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _apiService = ApiService();
  late TicketModel _currentTicket;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentTicket = widget.ticket;
  }

  Future<void> _updateStatus(TicketStatus newStatus) async {
    setState(() => _isUpdating = true);
    final success = await _apiService.updateTicketStatus(_currentTicket.id, newStatus);
    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (success) {
      setState(() {
        _currentTicket = _currentTicket.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อัปเดตสถานะเป็น "${_currentTicket.statusLabel}" สำเร็จ'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบตั๋วแจ้งปัญหานี้?'),
        content: const Text('เมื่อลบแล้วจะไม่สามารถกู้คืนข้อมูลได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบตั๋ว'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteTicket(_currentTicket.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบตั๋วแจ้งปัญหาเรียบร้อยแล้ว')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm น.');
    final isAdmin = _apiService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('ตั๋วแจ้งปัญหา #${_currentTicket.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'ลบตั๋ว',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _currentTicket.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _currentTicket.statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentTicket.status == TicketStatus.resolved
                        ? Icons.check_circle_rounded
                        : _currentTicket.status == TicketStatus.inProgress
                            ? Icons.pending_rounded
                            : Icons.schedule_rounded,
                    color: _currentTicket.statusColor,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สถานะ: ${_currentTicket.statusLabel}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentTicket.statusColor,
                          ),
                        ),
                        if (_currentTicket.updatedAt != null)
                          Text(
                            'อัปเดตล่าสุด: ${dateFormat.format(_currentTicket.updatedAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _currentTicket.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

            // Meta tags (Category & Priority)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(_currentTicket.categoryIcon, size: 18),
                  label: Text(_currentTicket.categoryLabel),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: BorderSide.none,
                ),
                Chip(
                  avatar: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentTicket.priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: Text('ความสำคัญ: ${_currentTicket.priorityLabel}'),
                  backgroundColor: _currentTicket.priorityColor.withValues(alpha: 0.12),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Box
            Text(
              'รายละเอียดปัญหา',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _currentTicket.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reporter Card
            Text(
              'ข้อมูลผู้แจ้งและเวลา',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.person, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTicket.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _currentTicket.userEmail,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('วันที่เปิดตั๋ว:', style: TextStyle(color: Color(0xFF64748B))),
                      Text(
                        dateFormat.format(_currentTicket.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action / Status Update Section
            Text(
              isAdmin ? 'จัดการสถานะงาน (สำหรับเจ้าหน้าที่ไอที)' : 'สถานะการทำงาน',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isUpdating)
              const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _currentTicket.status == TicketStatus.inProgress
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                            : Colors.white,
                        side: BorderSide(
                          color: _currentTicket.status == TicketStatus.inProgress
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFCBD5E1),
                          width: _currentTicket.status == TicketStatus.inProgress ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _updateStatus(TicketStatus.inProgress),
                      child: const Text(
                        'กำลังแก้ไข',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentTicket.status == TicketStatus.resolved
                            ? const Color(0xFF059669)
                            : const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _updateStatus(TicketStatus.resolved),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('แก้ไขเรียบร้อย'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
