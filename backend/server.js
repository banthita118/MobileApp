import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import path from 'path';
import { fileURLToPath } from 'url';
import 'dotenv/config';
import pool from './db.js';
import { requireAuth } from './auth.js';

const app = express();
const PORT = process.env.PORT || 3000;
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const frontendPath = path.join(__dirname, '../frontend');
const categories = ['computer', 'network', 'software', 'other'];
const priorities = ['low', 'medium', 'high', 'urgent'];
const statuses = ['open', 'in_progress', 'resolved'];
const validPassword = (password) => /^(?=.*[a-z])(?=.*[A-Z]).{6,}$/.test(password || '');

app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(express.static(frontendPath));

const profile = (user) => ({ id: user.id, name: user.name, email: user.email, role: user.role });
const makeToken = (user) => jwt.sign(profile(user), process.env.JWT_SECRET, { expiresIn: '7d' });
const isAdmin = (user) => user.role === 'admin';

app.get('/api/health', (_, res) => res.json({ status: 'ok', service: 'Service Desk API' }));
app.get('/', (_, res) => res.sendFile(path.join(frontendPath, 'index.html')));

app.post('/api/auth/register', async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    if (!name?.trim() || !email?.trim() || !validPassword(password)) return res.status(400).json({ message: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร และมีพิมพ์เล็กกับพิมพ์ใหญ่อย่างละ 1 ตัว' });
    const normalizedEmail = email.trim().toLowerCase();
    if ((await pool.query('SELECT id FROM users WHERE email = ?', [normalizedEmail])).length) return res.status(409).json({ message: 'อีเมลนี้ถูกใช้งานแล้ว กรุณาเข้าสู่ระบบ' });
    // Demo mode: store the chosen password directly so it is visible in phpMyAdmin.
    const result = await pool.query('INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)', [name.trim(), normalizedEmail, password, 'user']);
    const user = { id: Number(result.insertId), name: name.trim(), email: normalizedEmail, role: 'user' };
    res.status(201).json({ token: makeToken(user), user: profile(user) });
  } catch (error) { next(error); }
});

app.post('/api/auth/login', async (req, res, next) => {
  try {
    const rows = await pool.query('SELECT * FROM users WHERE email = ?', [req.body.email?.trim().toLowerCase()]);
    const user = rows[0];
    if (!user) return res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
    const submittedPassword = req.body.password || '';
    const isLegacyHash = user.password?.startsWith('$2');
    const passwordMatches = isLegacyHash ? await bcrypt.compare(submittedPassword, user.password) : submittedPassword === user.password;
    if (!passwordMatches) return res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
    // Convert previous bcrypt values to the demo password format after a successful login.
    if (isLegacyHash) await pool.query('UPDATE users SET password = ? WHERE id = ?', [submittedPassword, user.id]);
    res.json({ token: makeToken(user), user: profile(user) });
  } catch (error) { next(error); }
});

app.get('/api/auth/me', requireAuth, async (req, res, next) => {
  try {
    const user = (await pool.query('SELECT id, name, email, role FROM users WHERE id = ?', [req.user.id]))[0];
    if (!user) return res.status(401).json({ message: 'ไม่พบบัญชีผู้ใช้' });
    res.json({ token: makeToken(user), user: profile(user) });
  } catch (error) { next(error); }
});

app.get('/api/tickets', requireAuth, async (req, res, next) => {
  try {
    const sql = isAdmin(req.user)
      ? 'SELECT tickets.*, users.name AS requester_name, users.email AS requester_email FROM tickets JOIN users ON users.id = tickets.user_id ORDER BY tickets.created_at DESC'
      : 'SELECT * FROM tickets WHERE user_id = ? ORDER BY created_at DESC';
    res.json(await pool.query(sql, isAdmin(req.user) ? [] : [req.user.id]));
  } catch (error) { next(error); }
});

function validTicket(ticket) {
  return ticket.title?.trim() && ticket.description?.trim() && categories.includes(ticket.category) && priorities.includes(ticket.priority) && statuses.includes(ticket.status);
}

app.post('/api/tickets', requireAuth, async (req, res, next) => {
  try {
    const ticket = { category: 'other', priority: 'medium', status: 'open', ...req.body };
    if (!validTicket(ticket)) return res.status(400).json({ message: 'กรุณากรอกข้อมูลรายการแจ้งปัญหาให้ครบถ้วน' });
    const result = await pool.query('INSERT INTO tickets (user_id, title, description, category, priority, status) VALUES (?, ?, ?, ?, ?, ?)', [req.user.id, ticket.title.trim(), ticket.description.trim(), ticket.category, ticket.priority, ticket.status]);
    res.status(201).json((await pool.query('SELECT * FROM tickets WHERE id = ?', [result.insertId]))[0]);
  } catch (error) { next(error); }
});

app.put('/api/tickets/:id', requireAuth, async (req, res, next) => {
  try {
    if (!validTicket(req.body)) return res.status(400).json({ message: 'กรุณากรอกข้อมูลรายการแจ้งปัญหาให้ครบถ้วน' });
    const ticket = req.body;

    if (isAdmin(req.user)) {
      // Admin can update all fields including status
      const params = [ticket.title.trim(), ticket.description.trim(), ticket.category, ticket.priority, ticket.status, req.params.id];
      const result = await pool.query('UPDATE tickets SET title = ?, description = ?, category = ?, priority = ?, status = ? WHERE id = ?', params);
      if (!result.affectedRows) return res.status(404).json({ message: 'ไม่พบเคสนี้' });
    } else {
      // Regular user: can only update title, description, category, priority — NOT status
      const params = [ticket.title.trim(), ticket.description.trim(), ticket.category, ticket.priority, req.params.id, req.user.id];
      const result = await pool.query('UPDATE tickets SET title = ?, description = ?, category = ?, priority = ? WHERE id = ? AND user_id = ?', params);
      if (!result.affectedRows) return res.status(404).json({ message: 'ไม่พบเคสนี้ หรือไม่มีสิทธิ์แก้ไข' });
    }

    res.json((await pool.query('SELECT * FROM tickets WHERE id = ?', [req.params.id]))[0]);
  } catch (error) { next(error); }
});

app.delete('/api/tickets/:id', requireAuth, async (req, res, next) => {
  try {
    // Only admin can delete tickets
    if (!isAdmin(req.user)) return res.status(403).json({ message: 'ผู้ใช้งานทั่วไปไม่มีสิทธิ์ลบรายการแจ้งปัญหา' });
    const result = await pool.query('DELETE FROM tickets WHERE id = ?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'ไม่พบเคสนี้' });
    res.status(204).send();
  } catch (error) { next(error); }
});

app.use((error, _, res, __) => { console.error(error); res.status(500).json({ message: 'เกิดข้อผิดพลาดในเซิร์ฟเวอร์' }); });
app.listen(PORT, () => console.log(`Service Desk is running at http://localhost:${PORT}`));
