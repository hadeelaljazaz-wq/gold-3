"""
🤖 GOLDEN NIGHTMARE PRO - License Management Telegram Bot
========================================================

سيرفر إدارة التراخيص مع بوت تليجرام للتحكم الكامل

المتطلبات:
pip install python-telegram-bot flask python-dotenv

طريقة التشغيل:
1. أنشئ بوت جديد من @BotFather واحصل على التوكن
2. ضع التوكن في هذا الملف
3. شغل السيرفر: python license_server.py

الأوامر المتاحة:
/start - بداية
/generate [أيام] [اسم] - توليد كود جديد
/list - عرض جميع الأكواد
/info [code] - معلومات كود
/stop [code] - إيقاف كود
/activate [code] - تفعيل كود موقوف
/extend [code] [days] - تمديد كود
/stats - إحصائيات
"""

import os
import random
import sqlite3
from datetime import datetime, timedelta
from functools import wraps

from flask import Flask, request, jsonify
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes
import asyncio
import threading

# ═══════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════

# من @BotFather - @skalping_429_bot
TELEGRAM_BOT_TOKEN = "7791084974:AAGFIX4klFWRQKxw71FgYZdvWspAyYrqSzs"

# قائمة الأدمن (User IDs)
ADMIN_IDS = [590918137]  # Your Telegram ID

# إعدادات السيرفر
SERVER_HOST = "0.0.0.0"
SERVER_PORT = 5000

# قاعدة البيانات
DATABASE_FILE = "licenses.db"

# ═══════════════════════════════════════════════════════════════
# Database Setup
# ═══════════════════════════════════════════════════════════════

def init_database():
    """إنشاء قاعدة البيانات"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS licenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            license_key TEXT UNIQUE NOT NULL,
            device_id TEXT,
            user_name TEXT,
            telegram_user_id INTEGER,
            plan TEXT DEFAULT 'monthly',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            activated_at TIMESTAMP,
            expires_at TIMESTAMP,
            is_active BOOLEAN DEFAULT 1,
            is_used BOOLEAN DEFAULT 0,
            notes TEXT
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS activation_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            license_key TEXT,
            device_id TEXT,
            action TEXT,
            ip_address TEXT,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()
    print("[OK] Database initialized")

def get_db():
    """الحصول على اتصال بقاعدة البيانات"""
    conn = sqlite3.connect(DATABASE_FILE)
    conn.row_factory = sqlite3.Row
    return conn

# ═══════════════════════════════════════════════════════════════
# License Code Generator
# ═══════════════════════════════════════════════════════════════

def generate_license_code():
    """توليد كود ترخيص فريد - Format: GNP-XXXX-XXXX-XXXX"""
    chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    segments = []
    for _ in range(3):
        segment = ''.join(random.choices(chars, k=4))
        segments.append(segment)
    return f"GNP-{'-'.join(segments)}"

def create_license(plan='monthly', days=30, user_name=None, telegram_user_id=None, notes=None):
    """إنشاء ترخيص جديد"""
    license_key = generate_license_code()
    expires_at = datetime.now() + timedelta(days=days)
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        INSERT INTO licenses (license_key, plan, expires_at, user_name, telegram_user_id, notes)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (license_key, plan, expires_at, user_name, telegram_user_id, notes))
    
    conn.commit()
    conn.close()
    
    return {
        'license_key': license_key,
        'plan': plan,
        'expires_at': expires_at.isoformat(),
        'days': days
    }

# ═══════════════════════════════════════════════════════════════
# Flask API Server
# ═══════════════════════════════════════════════════════════════

app = Flask(__name__)

@app.route('/activate', methods=['POST'])
def activate_license():
    """تفعيل الترخيص"""
    data = request.json
    license_key = data.get('license_key', '').upper()
    device_id = data.get('device_id')
    
    if not license_key or not device_id:
        return jsonify({'success': False, 'message': 'بيانات ناقصة'}), 400
    
    conn = get_db()
    cursor = conn.cursor()
    
    # البحث عن الترخيص
    cursor.execute('SELECT * FROM licenses WHERE license_key = ?', (license_key,))
    license_row = cursor.fetchone()
    
    if not license_row:
        conn.close()
        return jsonify({'success': False, 'message': 'كود غير صالح ❌'}), 400
    
    # التحقق من الحالة
    if not license_row['is_active']:
        conn.close()
        return jsonify({'success': False, 'message': 'الكود موقوف من الإدارة 🚫'}), 423
    
    # التحقق من الصلاحية
    expires_at = datetime.fromisoformat(license_row['expires_at'])
    if datetime.now() > expires_at:
        conn.close()
        return jsonify({'success': False, 'message': 'الكود منتهي الصلاحية ⏰'}), 410
    
    # التحقق من الجهاز
    if license_row['is_used'] and license_row['device_id'] != device_id:
        conn.close()
        return jsonify({'success': False, 'message': 'الكود مستخدم على جهاز آخر 📱'}), 403
    
    # تفعيل الترخيص
    cursor.execute('''
        UPDATE licenses 
        SET device_id = ?, is_used = 1, activated_at = ?
        WHERE license_key = ?
    ''', (device_id, datetime.now(), license_key))
    
    # تسجيل العملية
    cursor.execute('''
        INSERT INTO activation_logs (license_key, device_id, action, ip_address)
        VALUES (?, ?, 'activate', ?)
    ''', (license_key, device_id, request.remote_addr))
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'success': True,
        'message': 'تم التفعيل بنجاح! 🎉',
        'expires_at': license_row['expires_at'],
        'plan': license_row['plan'],
        'user_name': license_row['user_name']
    })

@app.route('/verify', methods=['POST'])
def verify_license():
    """التحقق من الترخيص"""
    data = request.json
    license_key = data.get('license_key', '').upper()
    device_id = data.get('device_id')
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM licenses WHERE license_key = ?', (license_key,))
    license_row = cursor.fetchone()
    
    if not license_row:
        conn.close()
        return jsonify({'is_active': False, 'message': 'كود غير موجود'})
    
    # التحقق من الجهاز
    if license_row['device_id'] != device_id:
        conn.close()
        return jsonify({'is_active': False, 'message': 'جهاز غير مصرح'})
    
    # التحقق من الحالة
    if not license_row['is_active']:
        conn.close()
        return jsonify({'is_active': False, 'message': 'الكود موقوف'})
    
    # التحقق من الصلاحية
    expires_at = datetime.fromisoformat(license_row['expires_at'])
    if datetime.now() > expires_at:
        conn.close()
        return jsonify({'is_active': False, 'message': 'منتهي الصلاحية'})
    
    # تسجيل التحقق
    cursor.execute('''
        INSERT INTO activation_logs (license_key, device_id, action, ip_address)
        VALUES (?, ?, 'verify', ?)
    ''', (license_key, device_id, request.remote_addr))
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'is_active': True,
        'expires_at': license_row['expires_at'],
        'plan': license_row['plan']
    })

@app.route('/deactivate', methods=['POST'])
def deactivate_license():
    """إلغاء تفعيل من جهاز"""
    data = request.json
    license_key = data.get('license_key', '').upper()
    device_id = data.get('device_id')
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        UPDATE licenses 
        SET device_id = NULL, is_used = 0
        WHERE license_key = ? AND device_id = ?
    ''', (license_key, device_id))
    
    cursor.execute('''
        INSERT INTO activation_logs (license_key, device_id, action, ip_address)
        VALUES (?, ?, 'deactivate', ?)
    ''', (license_key, device_id, request.remote_addr))
    
    conn.commit()
    conn.close()
    
    return jsonify({'success': True})

# ═══════════════════════════════════════════════════════════════
# Telegram Bot Commands
# ═══════════════════════════════════════════════════════════════

def admin_only(func):
    """ديكوريتور للتحقق من الأدمن"""
    @wraps(func)
    async def wrapper(update: Update, context: ContextTypes.DEFAULT_TYPE):
        user_id = update.effective_user.id
        if user_id not in ADMIN_IDS:
            await update.message.reply_text("⛔ غير مصرح لك باستخدام هذا الأمر")
            return
        return await func(update, context)
    return wrapper

async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """أمر البداية"""
    user = update.effective_user
    
    keyboard = [
        [InlineKeyboardButton("🔑 توليد كود", callback_data='gen_monthly')],
        [InlineKeyboardButton("📋 قائمة الأكواد", callback_data='list_codes')],
        [InlineKeyboardButton("📊 الإحصائيات", callback_data='stats')],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.message.reply_text(
        f"مرحباً {user.first_name}! 👋\n\n"
        "🎛️ لوحة تحكم GOLDEN NIGHTMARE PRO\n\n"
        "اختر أحد الخيارات:",
        reply_markup=reply_markup
    )

@admin_only
async def generate_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """توليد كود جديد"""
    # الخيارات الافتراضية
    days = 30
    plan = 'monthly'
    user_name = None
    
    # معالجة المعاملات
    args = context.args
    if args:
        if args[0].isdigit():
            days = int(args[0])
        if len(args) > 1:
            user_name = ' '.join(args[1:])
    
    # تحديد الخطة
    if days <= 7:
        plan = 'trial'
    elif days <= 30:
        plan = 'monthly'
    elif days <= 90:
        plan = 'quarterly'
    elif days <= 365:
        plan = 'yearly'
    else:
        plan = 'lifetime'
    
    # إنشاء الكود
    result = create_license(
        plan=plan,
        days=days,
        user_name=user_name,
        telegram_user_id=update.effective_user.id
    )
    
    message = (
        "✅ *تم إنشاء كود جديد!*\n\n"
        f"🔑 الكود:\n`{result['license_key']}`\n\n"
        f"📅 المدة: {days} يوم\n"
        f"📦 الخطة: {plan}\n"
        f"⏰ ينتهي: {result['expires_at'][:10]}\n"
    )
    
    if user_name:
        message += f"👤 للمستخدم: {user_name}\n"
    
    message += "\n_انسخ الكود وأرسله للعميل_"
    
    await update.message.reply_text(message, parse_mode='Markdown')

@admin_only
async def list_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """عرض قائمة الأكواد"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT * FROM licenses 
        ORDER BY created_at DESC 
        LIMIT 20
    ''')
    licenses = cursor.fetchall()
    conn.close()
    
    if not licenses:
        await update.message.reply_text("📭 لا توجد أكواد")
        return
    
    message = "📋 *آخر 20 كود:*\n\n"
    
    for lic in licenses:
        status = "🟢" if lic['is_active'] else "🔴"
        used = "✅" if lic['is_used'] else "⚪"
        expires = datetime.fromisoformat(lic['expires_at'])
        expired = "⏰" if datetime.now() > expires else ""
        
        message += (
            f"{status}{used}{expired} `{lic['license_key']}`\n"
            f"   └ {lic['plan']} | {expires.strftime('%Y-%m-%d')}"
        )
        if lic['user_name']:
            message += f" | {lic['user_name']}"
        message += "\n\n"
    
    await update.message.reply_text(message, parse_mode='Markdown')

@admin_only
async def info_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """معلومات كود محدد"""
    if not context.args:
        await update.message.reply_text("❌ أدخل الكود: /info GNP-XXXX-XXXX-XXXX")
        return
    
    license_key = context.args[0].upper()
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM licenses WHERE license_key = ?', (license_key,))
    lic = cursor.fetchone()
    
    if not lic:
        await update.message.reply_text("❌ كود غير موجود")
        conn.close()
        return
    
    # جلب سجل التفعيلات
    cursor.execute('''
        SELECT * FROM activation_logs 
        WHERE license_key = ? 
        ORDER BY timestamp DESC 
        LIMIT 5
    ''', (license_key,))
    logs = cursor.fetchall()
    conn.close()
    
    status = "🟢 فعال" if lic['is_active'] else "🔴 موقوف"
    used = "✅ مستخدم" if lic['is_used'] else "⚪ غير مستخدم"
    expires = datetime.fromisoformat(lic['expires_at'])
    days_left = (expires - datetime.now()).days
    
    message = (
        f"🔑 *معلومات الكود*\n\n"
        f"الكود: `{lic['license_key']}`\n"
        f"الحالة: {status}\n"
        f"الاستخدام: {used}\n"
        f"الخطة: {lic['plan']}\n"
        f"ينتهي: {expires.strftime('%Y-%m-%d')}\n"
        f"متبقي: {days_left} يوم\n"
    )
    
    if lic['user_name']:
        message += f"المستخدم: {lic['user_name']}\n"
    
    if lic['device_id']:
        message += f"الجهاز: `{lic['device_id'][:20]}...`\n"
    
    if logs:
        message += "\n📝 *آخر النشاطات:*\n"
        for log in logs:
            message += f"  • {log['action']} - {log['timestamp'][:16]}\n"
    
    # أزرار التحكم
    keyboard = [
        [
            InlineKeyboardButton(
                "🔴 إيقاف" if lic['is_active'] else "🟢 تفعيل",
                callback_data=f"toggle_{license_key}"
            ),
            InlineKeyboardButton("➕ تمديد", callback_data=f"extend_{license_key}"),
        ],
        [InlineKeyboardButton("🗑️ حذف", callback_data=f"delete_{license_key}")],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.message.reply_text(
        message, 
        parse_mode='Markdown',
        reply_markup=reply_markup
    )

@admin_only
async def stop_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """إيقاف كود"""
    if not context.args:
        await update.message.reply_text("❌ أدخل الكود: /stop GNP-XXXX-XXXX-XXXX")
        return
    
    license_key = context.args[0].upper()
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        UPDATE licenses SET is_active = 0 WHERE license_key = ?
    ''', (license_key,))
    
    if cursor.rowcount > 0:
        conn.commit()
        await update.message.reply_text(f"🔴 تم إيقاف الكود:\n`{license_key}`", parse_mode='Markdown')
    else:
        await update.message.reply_text("❌ كود غير موجود")
    
    conn.close()

@admin_only
async def activate_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """تفعيل كود موقوف"""
    if not context.args:
        await update.message.reply_text("❌ أدخل الكود: /activate GNP-XXXX-XXXX-XXXX")
        return
    
    license_key = context.args[0].upper()
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        UPDATE licenses SET is_active = 1 WHERE license_key = ?
    ''', (license_key,))
    
    if cursor.rowcount > 0:
        conn.commit()
        await update.message.reply_text(f"🟢 تم تفعيل الكود:\n`{license_key}`", parse_mode='Markdown')
    else:
        await update.message.reply_text("❌ كود غير موجود")
    
    conn.close()

@admin_only
async def extend_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """تمديد كود"""
    if len(context.args) < 2:
        await update.message.reply_text("❌ الاستخدام: /extend GNP-XXXX-XXXX-XXXX 30")
        return
    
    license_key = context.args[0].upper()
    days = int(context.args[1])
    
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT expires_at FROM licenses WHERE license_key = ?', (license_key,))
    row = cursor.fetchone()
    
    if not row:
        await update.message.reply_text("❌ كود غير موجود")
        conn.close()
        return
    
    current_expiry = datetime.fromisoformat(row['expires_at'])
    # إذا منتهي، ابدأ من اليوم
    if current_expiry < datetime.now():
        current_expiry = datetime.now()
    
    new_expiry = current_expiry + timedelta(days=days)
    
    cursor.execute('''
        UPDATE licenses SET expires_at = ? WHERE license_key = ?
    ''', (new_expiry.isoformat(), license_key))
    
    conn.commit()
    conn.close()
    
    await update.message.reply_text(
        f"✅ تم تمديد الكود:\n"
        f"`{license_key}`\n\n"
        f"📅 ينتهي الآن: {new_expiry.strftime('%Y-%m-%d')}",
        parse_mode='Markdown'
    )

@admin_only
async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """إحصائيات"""
    conn = get_db()
    cursor = conn.cursor()
    
    # إجمالي الأكواد
    cursor.execute('SELECT COUNT(*) FROM licenses')
    total = cursor.fetchone()[0]
    
    # الأكواد الفعالة
    cursor.execute('SELECT COUNT(*) FROM licenses WHERE is_active = 1')
    active = cursor.fetchone()[0]
    
    # الأكواد المستخدمة
    cursor.execute('SELECT COUNT(*) FROM licenses WHERE is_used = 1')
    used = cursor.fetchone()[0]
    
    # المنتهية
    cursor.execute('''
        SELECT COUNT(*) FROM licenses 
        WHERE expires_at < datetime('now')
    ''')
    expired = cursor.fetchone()[0]
    
    # حسب الخطة
    cursor.execute('''
        SELECT plan, COUNT(*) FROM licenses GROUP BY plan
    ''')
    by_plan = cursor.fetchall()
    
    conn.close()
    
    message = (
        "📊 *إحصائيات النظام*\n\n"
        f"📦 إجمالي الأكواد: {total}\n"
        f"🟢 فعالة: {active}\n"
        f"✅ مستخدمة: {used}\n"
        f"⏰ منتهية: {expired}\n\n"
        "*حسب الخطة:*\n"
    )
    
    for plan, count in by_plan:
        message += f"  • {plan}: {count}\n"
    
    await update.message.reply_text(message, parse_mode='Markdown')

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """معالجة الأزرار"""
    query = update.callback_query
    await query.answer()
    
    user_id = query.from_user.id
    if user_id not in ADMIN_IDS:
        await query.edit_message_text("⛔ غير مصرح")
        return
    
    data = query.data
    
    if data == 'gen_monthly':
        result = create_license(plan='monthly', days=30)
        await query.edit_message_text(
            f"✅ *كود جديد (30 يوم):*\n\n`{result['license_key']}`",
            parse_mode='Markdown'
        )
    
    elif data == 'list_codes':
        await query.edit_message_text("استخدم /list لعرض الأكواد")
    
    elif data == 'stats':
        await query.edit_message_text("استخدم /stats للإحصائيات")
    
    elif data.startswith('toggle_'):
        license_key = data.replace('toggle_', '')
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute('SELECT is_active FROM licenses WHERE license_key = ?', (license_key,))
        row = cursor.fetchone()
        
        if row:
            new_status = 0 if row['is_active'] else 1
            cursor.execute('UPDATE licenses SET is_active = ? WHERE license_key = ?', 
                         (new_status, license_key))
            conn.commit()
            
            status = "🟢 فعال" if new_status else "🔴 موقوف"
            await query.edit_message_text(f"تم تغيير حالة الكود إلى: {status}")
        
        conn.close()
    
    elif data.startswith('extend_'):
        license_key = data.replace('extend_', '')
        keyboard = [
            [
                InlineKeyboardButton("7 أيام", callback_data=f"ext7_{license_key}"),
                InlineKeyboardButton("30 يوم", callback_data=f"ext30_{license_key}"),
            ],
            [
                InlineKeyboardButton("90 يوم", callback_data=f"ext90_{license_key}"),
                InlineKeyboardButton("365 يوم", callback_data=f"ext365_{license_key}"),
            ],
        ]
        await query.edit_message_text(
            "اختر مدة التمديد:",
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
    
    elif data.startswith('ext'):
        parts = data.split('_')
        days = int(parts[0].replace('ext', ''))
        license_key = parts[1]
        
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute('SELECT expires_at FROM licenses WHERE license_key = ?', (license_key,))
        row = cursor.fetchone()
        
        if row:
            current = datetime.fromisoformat(row['expires_at'])
            if current < datetime.now():
                current = datetime.now()
            new_expiry = current + timedelta(days=days)
            
            cursor.execute('UPDATE licenses SET expires_at = ? WHERE license_key = ?',
                         (new_expiry.isoformat(), license_key))
            conn.commit()
            
            await query.edit_message_text(
                f"✅ تم تمديد {days} يوم\n"
                f"ينتهي: {new_expiry.strftime('%Y-%m-%d')}"
            )
        
        conn.close()

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

def run_flask():
    """تشغيل سيرفر Flask"""
    app.run(host=SERVER_HOST, port=SERVER_PORT, threaded=True)

def run_bot_in_thread():
    """تشغيل بوت تليجرام في thread منفصل"""
    try:
        # إنشاء event loop جديد للـ thread
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        application = Application.builder().token(TELEGRAM_BOT_TOKEN).build()
        
        # إضافة الأوامر
        application.add_handler(CommandHandler("start", start_command))
        application.add_handler(CommandHandler("generate", generate_command))
        application.add_handler(CommandHandler("gen", generate_command))
        application.add_handler(CommandHandler("list", list_command))
        application.add_handler(CommandHandler("info", info_command))
        application.add_handler(CommandHandler("stop", stop_command))
        application.add_handler(CommandHandler("activate", activate_command))
        application.add_handler(CommandHandler("extend", extend_command))
        application.add_handler(CommandHandler("stats", stats_command))
        application.add_handler(CallbackQueryHandler(button_callback))
        
        print("[OK] Telegram Bot started!")
        print(f"[OK] Bot ready to receive commands from admin ID: {ADMIN_IDS[0]}")
        
        # تشغيل البوت
        loop.run_until_complete(application.run_polling())
    except Exception as e:
        print(f"[ERROR] Bot failed to start: {e}")

def main():
    """نقطة البداية"""
    print("=" * 60)
    print("GOLDEN NIGHTMARE PRO - License Server")
    print("=" * 60)
    
    # تهيئة قاعدة البيانات
    init_database()
    
    # تشغيل Flask في thread منفصل
    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()
    print(f"[OK] API Server running on http://{SERVER_HOST}:{SERVER_PORT}")
    print(f"   - POST /activate")
    print(f"   - POST /verify")
    print(f"   - POST /deactivate")
    print()
    
    # تشغيل البوت في thread منفصل
    bot_thread = threading.Thread(target=run_bot_in_thread, daemon=True)
    bot_thread.start()
    
    # إبقاء البرنامج شغال
    try:
        while True:
            import time
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[OK] Shutting down...")

if __name__ == '__main__':
    main()
