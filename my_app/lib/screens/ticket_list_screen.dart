import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  TicketStatus? _selectedStatus;
  TicketCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _apiService,
      builder: (context, _) {
        final tickets = _apiService.getFilteredTickets(
          statusFilter: _selectedStatus,
          categoryFilter: _selectedCategory,
          searchQuery: _searchQuery,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('รายการแจ้งปัญหา'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _apiService.fetchTickets(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาหัวข้อ, รหัส #ตั๋ว หรือผู้แจ้ง...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Filter Chips (Status)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('ทุกสถานะ'),
                      selected: _selectedStatus == null,
                      onSelected: (_) => setState(() => _selectedStatus = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('รอดำเนินการ'),
                      selected: _selectedStatus == TicketStatus.open,
                      selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                      onSelected: (sel) => setState(
                          () => _selectedStatus = sel ? TicketStatus.open : null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('กำลังแก้ไข'),
                      selected: _selectedStatus == TicketStatus.inProgress,
                      selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      onSelected: (sel) => setState(() =>
                          _selectedStatus = sel ? TicketStatus.inProgress : null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('แก้ไขเรียบร้อย'),
                      selected: _selectedStatus == TicketStatus.resolved,
                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                      onSelected: (sel) => setState(() =>
                          _selectedStatus = sel ? TicketStatus.resolved : null),
                    ),
                  ],
                ),
              ),

              // Filter Chips (Category)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('ทุกหมวดหมู่'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.computer_rounded, size: 16),
                      label: const Text('คอมพิวเตอร์'),
                      selected: _selectedCategory == TicketCategory.computer,
                      onSelected: (sel) => setState(() => _selectedCategory =
                          sel ? TicketCategory.computer : null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.wifi_rounded, size: 16),
                      label: const Text('เครือข่าย'),
                      selected: _selectedCategory == TicketCategory.network,
                      onSelected: (sel) => setState(() => _selectedCategory =
                          sel ? TicketCategory.network : null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.apps_rounded, size: 16),
                      label: const Text('ซอฟต์แวร์'),
                      selected: _selectedCategory == TicketCategory.software,
                      onSelected: (sel) => setState(() => _selectedCategory =
                          sel ? TicketCategory.software : null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.build_circle_rounded, size: 16),
                      label: const Text('อื่นๆ'),
                      selected: _selectedCategory == TicketCategory.other,
                      onSelected: (sel) => setState(() =>
                          _selectedCategory = sel ? TicketCategory.other : null),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // Tickets List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _apiService.fetchTickets(),
                  child: tickets.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 54, color: Color(0xFFCBD5E1)),
                                  SizedBox(height: 12),
                                  Text(
                                    'ไม่พบรายการแจ้งปัญหาที่ตรงกับเงื่อนไข',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return TicketCard(
                              ticket: ticket,
                              showUser: _apiService.isAdmin,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TicketDetailScreen(ticket: ticket),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
