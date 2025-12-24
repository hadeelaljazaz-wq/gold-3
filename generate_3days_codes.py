"""
توليد 20 كود تفعيل - صلاحية 3 أيام فقط
للتجربة أو الاشتراكات القصيرة
"""
import random
import string
import json
from datetime import datetime, timedelta

def generate_code():
    """توليد كود عشوائي بصيغة GNP-XXXX-XXXX-XXXX"""
    chars = string.ascii_uppercase + string.digits
    parts = []
    for _ in range(3):
        part = ''.join(random.choices(chars, k=4))
        parts.append(part)
    return f"GNP-{'-'.join(parts)}"

def generate_3days_codes(count=20):
    """توليد أكواد صلاحيتها 3 أيام"""
    codes = []
    used_codes = set()
    
    # تاريخ انتهاء الصلاحية (3 أيام من الآن)
    expiry_date = (datetime.now() + timedelta(days=3)).isoformat()
    
    while len(codes) < count:
        code = generate_code()
        if code not in used_codes:
            used_codes.add(code)
            codes.append({
                'code': code,
                'days': 3,
                'expiry_date': expiry_date,
                'status': 'active',
                'created_at': datetime.now().isoformat()
            })
    
    return codes

if __name__ == '__main__':
    import sys
    sys.stdout.reconfigure(encoding='utf-8')
    
    print('=' * 60)
    print('توليد أكواد تجريبية - صلاحية 3 أيام')
    print('=' * 60)
    
    codes = generate_3days_codes(20)
    
    # حفظ في ملف JSON منفصل
    filename = 'valid_codes_3days.json'
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(codes, f, ensure_ascii=False, indent=2)
    
    print(f'\nتم توليد {len(codes)} كود بنجاح!')
    print(f'صلاحية كل كود: 3 أيام')
    print(f'تنتهي في: {codes[0]["expiry_date"].split("T")[0]}')
    print(f'محفوظة في: {filename}')
    
    print('\n' + '=' * 60)
    print('جميع الأكواد:')
    print('=' * 60)
    
    for i, code in enumerate(codes, 1):
        print(f'{i:2d}. {code["code"]}')
    
    print('\n' + '=' * 60)
    print('انتهى!')
    print('=' * 60)
