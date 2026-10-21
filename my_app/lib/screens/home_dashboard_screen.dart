import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeDashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: apiService,
      builder: (context, _) {
        final user = apiService.currentUser;
        final stats = apiService.getStatistics();
        final recentTickets = apiService.getFilteredTickets().take(4).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'ผู้ใช้งาน',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          apiService.isAdmin
                              ? 'เจ้าหน้าที่ไอที (Admin)'
                              : 'พนักงานทั่วไป (User)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'รีเฟรชข้อมูล',
                onPressed: () => apiService.fetchTickets(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => apiService.fetchTickets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Call to Action Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332563EB),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on_rounded,
                                color: Colors.amberAccent, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Service Desk Support',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'พบปัญหาด้านคอมพิวเตอร์\nหรือระบบเครือข่าย?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateTicketScreen(
                                  onCreated: () => apiService.fetchTickets(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              size: 18),
                          label: const Text(
                            'เปิดตั๋วแจ้งปัญหาทันที',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Stat Summary Cards
                  Text(
                    'ภาพรวมรายการแจ้งปัญหา',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(
                        title: 'ทั้งหมด',
                        count: stats['total'] ?? 0,
                        color: const Color(0xFF3B82F6),
                        icon: Icons.assignment_rounded,
                        onTap: () => onTabChange(1),
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'รอดำเนินการ',
                        count: stats['open'] ?? 0,
                        color: const Color(0xFF6366F1),
                        icon: Icons.hourglass_top_rounded,
                        onTap: () => onTabChange(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatCard(
                        title: 'กำลังแก้ไข',
                        count: stats['in_progress'] ?? 0,
                        color: const Color(0xFFF59E0B),
                        icon: Icons.engineering_rounded,
                        onTap: () => onTabChange(1),
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'เสร็จสิ้นแล้ว',
                        count: stats['resolved'] ?? 0,
                        color: const Color(0xFF10B981),
                        icon: Icons.check_circle_outline_rounded,
                        onTap: () => onTabChange(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Tickets Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'รายการแจ้งปัญหาล่าสุด',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onTabChange(1),
                        child: const Text('ดูทั้งหมด'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (recentTickets.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 10),
                          Text(
                            'ยังไม่มีรายการแจ้งปัญหา',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...recentTickets.map((t) => TicketCard(
                          ticket: t,
                          showUser: apiService.isAdmin,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailScreen(ticket: t),
                              ),
                            );
                          },
                        )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
