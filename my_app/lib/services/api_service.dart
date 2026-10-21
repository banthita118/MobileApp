import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/ticket_model.dart';

class ApiService extends ChangeNotifier {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _determineDefaultBaseUrl();
  }

  // Backend settings
  bool _useMock = false;
  String _baseUrl = 'http://localhost:3000/api';
  String? _authToken;

  bool get useMock => _useMock;
  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;

  void _determineDefaultBaseUrl() {
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          // IP of this computer on Wi-Fi for physical phones
          _baseUrl = 'http://192.168.1.111:3000/api';
        } else {
          _baseUrl = 'http://localhost:3000/api';
        }
      } catch (_) {
        _baseUrl = 'http://localhost:3000/api';
      }
    } else {
      _baseUrl = 'http://localhost:3000/api';
    }
  }

  void setMockMode(bool enabled) {
    _useMock = enabled;
    if (_useMock && _tickets.isEmpty) {
      _initMockFallback();
    }
    notifyListeners();
  }

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    notifyListeners();
  }

  // Current session
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Cached tickets
  final List<TicketModel> _tickets = [];
  List<TicketModel> get allTickets => List.unmodifiable(_tickets);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Auth: Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = UserModel(
        id: 1,
        name: email.split('@').first,
        email: email.trim(),
        role: email.contains('admin') ? 'admin' : 'user',
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return {'success': true};
    }

    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) {
        _authToken = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        await fetchTickets();
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _lastError = data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('API login exception: $e');
      _lastError = 'ไม่สามารถเชื่อมต่อฐานข้อมูลได้ ($e)';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': false, 'message': _lastError};
  }

  // Auth: Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch % 1000,
        name: name,
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return {'success': true};
    }

    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 201 || res.statusCode == 200) {
        _authToken = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        await fetchTickets();
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _lastError = data['message'] ?? 'สมัครสมาชิกไม่สำเร็จ (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('API register exception: $e');
      _lastError = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ ($e)';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': false, 'message': _lastError};
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
    _tickets.clear();
    notifyListeners();
  }

  // Fetch Tickets from MySQL
  Future<void> fetchTickets() async {
    if (_useMock) {
      if (_tickets.isEmpty) _initMockFallback();
      return;
    }

    if (_authToken == null) return;

    try {
      final res = await http
          .get(
            Uri.parse('$_baseUrl/tickets'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(res.bodyBytes));
        _tickets.clear();
        for (var item in list) {
          _tickets.add(TicketModel.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch tickets error: $e');
    }
  }

  // Create Ticket in MySQL
  Future<bool> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    if (_currentUser == null) return false;

    if (_useMock) {
      final newTicket = TicketModel(
        id: 100 + _tickets.length + 1,
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        userEmail: _currentUser!.email,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );
      _tickets.insert(0, newTicket);
      notifyListeners();
      return true;
    }

    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/tickets'),
            headers: _authHeaders,
            body: jsonEncode({
              'title': title.trim(),
              'description': description.trim(),
              'category': TicketModel.categoryToString(category),
              'priority': TicketModel.priorityToString(priority),
              'status': 'open',
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        data['requester_name'] = _currentUser?.name;
        data['requester_email'] = _currentUser?.email;
        _tickets.insert(0, TicketModel.fromJson(data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Create ticket error: $e');
    }
    return false;
  }

  // Update Ticket Status in MySQL
  Future<bool> updateTicketStatus(int ticketId, TicketStatus newStatus) async {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) return false;
    final current = _tickets[idx];

    if (_useMock) {
      _tickets[idx] = current.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }

    try {
      final res = await http
          .put(
            Uri.parse('$_baseUrl/tickets/$ticketId'),
            headers: _authHeaders,
            body: jsonEncode({
              'title': current.title,
              'description': current.description,
              'category': TicketModel.categoryToString(current.category),
              'priority': TicketModel.priorityToString(current.priority),
              'status': TicketModel.statusToString(newStatus),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        _tickets[idx] = current.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update status error: $e');
    }
    return false;
  }

  // Delete Ticket in MySQL
  Future<bool> deleteTicket(int ticketId) async {
    if (_useMock) {
      _tickets.removeWhere((t) => t.id == ticketId);
      notifyListeners();
      return true;
    }

    try {
      final res = await http
          .delete(
            Uri.parse('$_baseUrl/tickets/$ticketId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 204) {
        _tickets.removeWhere((t) => t.id == ticketId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete ticket error: $e');
    }
    return false;
  }

  // Filter tickets
  List<TicketModel> getFilteredTickets({
    TicketStatus? statusFilter,
    TicketCategory? categoryFilter,
    TicketPriority? priorityFilter,
    String? searchQuery,
    bool ownOnly = false,
  }) {
    return _tickets.where((t) {
      if (ownOnly || (!isAdmin && _currentUser != null)) {
        if (t.userId != _currentUser?.id) return false;
      }

      if (statusFilter != null && t.status != statusFilter) return false;
      if (categoryFilter != null && t.category != categoryFilter) return false;
      if (priorityFilter != null && t.priority != priorityFilter) return false;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description.toLowerCase().contains(q);
        final matchUser = t.userName.toLowerCase().contains(q);
        final matchId = '#${t.id}'.contains(q) || t.id.toString() == q;
        if (!matchTitle && !matchDesc && !matchUser && !matchId) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Statistics
  Map<String, int> getStatistics() {
    final list = isAdmin
        ? _tickets
        : _tickets.where((t) => t.userId == _currentUser?.id).toList();

    return {
      'total': list.length,
      'open': list.where((t) => t.status == TicketStatus.open).length,
      'in_progress':
          list.where((t) => t.status == TicketStatus.inProgress).length,
      'resolved': list.where((t) => t.status == TicketStatus.resolved).length,
    };
  }

  void _initMockFallback() {
    _tickets.addAll([
      TicketModel(
        id: 101,
        userId: 1,
        userName: 'Banthita Sondee',
        userEmail: 'pmexn030@gmail.com',
        title: 'เครื่องคอมพิวเตอร์เปิดไม่ติด มีไฟกระพริบ',
        description: 'กดปุ่ม Power แล้วหน้าจอไม่ติด มีเสียง Beep 3 ครั้ง',
        category: TicketCategory.computer,
        priority: TicketPriority.urgent,
        status: TicketStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }
}
