import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class CreateTicketScreen extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreateTicketScreen({super.key, this.onCreated});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  TicketCategory _category = TicketCategory.computer;
  TicketPriority _priority = TicketPriority.medium;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'cat': TicketCategory.computer,
      'label': 'คอมพิวเตอร์',
      'icon': Icons.computer_rounded,
    },
    {
      'cat': TicketCategory.network,
      'label': 'เครือข่าย/เน็ต',
      'icon': Icons.wifi_rounded,
    },
    {
      'cat': TicketCategory.software,
      'label': 'ซอฟต์แวร์',
      'icon': Icons.apps_rounded,
    },
    {
      'cat': TicketCategory.other,
      'label': 'ปัญหาอื่นๆ',
      'icon': Icons.build_circle_rounded,
    },
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'pri': TicketPriority.low, 'label': 'ต่ำ', 'color': const Color(0xFF10B981)},
    {'pri': TicketPriority.medium, 'label': 'ปานกลาง', 'color': const Color(0xFFF59E0B)},
    {'pri': TicketPriority.high, 'label': 'สูง', 'color': const Color(0xFFF97316)},
    {'pri': TicketPriority.urgent, 'label': 'เร่งด่วน', 'color': const Color(0xFFEF4444)},
  ];

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final success = await _apiService.createTicket(
      title: _title,
      description: _description,
      category: _category,
      priority: _priority,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.onCreated?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ส่งตั๋วแจ้งปัญหาเรียบร้อยแล้ว'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _title = '';
        _description = '';
        _category = TicketCategory.computer;
        _priority = TicketPriority.medium;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการสร้างตั๋ว'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('แจ้งปัญหาไอทีใหม่'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'กรุณากรอกข้อมูลปัญหาให้ครบถ้วน เพื่อให้เจ้าหน้าที่ไอทีช่วยแก้ไขได้อย่างรวดเร็ว',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Input
              Text(
                'หัวข้อปัญหา *',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'เช่น เครื่องคอมพิวเตอร์เปิดไม่ติด, ปริ้นเตอร์ไม่ออก',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'กรุณาระบุหัวข้อปัญหา'
                    : null,
                onSaved: (val) => _title = val?.trim() ?? '',
              ),
              const SizedBox(height: 20),

              // Category Selector
              Text(
                'หมวดหมู่ปัญหา *',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
                children: _categories.map((c) {
                  final isSelected = _category == c['cat'];
                  return InkWell(
                    onTap: () => setState(() => _category = c['cat']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            c['icon'],
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c['label'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority Selector
              Text(
                'ระดับความสำคัญ *',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((p) {
                  final isSelected = _priority == p['pri'];
                  final color = p['color'] as Color;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _priority = p['pri']),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? color : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Description Text Area
              Text(
                'รายละเอียดของปัญหา *',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'อธิบายปัญหาที่พบ เช่น ข้อความ Error, ขั้นตอนก่อนเกิดปัญหา, อาการที่พบ...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'กรุณากรอกรายละเอียดปัญหา'
                    : null,
                onSaved: (val) => _description = val?.trim() ?? '',
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitTicket,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isLoading ? 'กำลังส่งข้อมูล...' : 'ส่งตั๋วแจ้งปัญหา'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
