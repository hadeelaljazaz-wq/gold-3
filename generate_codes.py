"""
توليد 100 كود تفعيل للتطبيق
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

def generate_codes(count=100):
    """توليد عدد من الأكواد"""
    codes = []
    used_codes = set()
    
    # تاريخ انتهاء الصلاحية (30 يوم من الآن)
    expiry_date = (datetime.now() + timedelta(days=30)).isoformat()
    
    while len(codes) < count:
        code = generate_code()
        if code not in used_codes:
            used_codes.add(code)
            codes.append({
                'code': code,
                'days': 30,
                'expiry_date': expiry_date,
                'status': 'active',
                'created_at': datetime.now().isoformat()
            })
    
    return codes

if __name__ == '__main__':
    print('Generating 100 activation codes...')
    codes = generate_codes(100)
    
    # حفظ في ملف JSON
    with open('valid_codes.json', 'w', encoding='utf-8') as f:
        json.dump(codes, f, ensure_ascii=False, indent=2)
    
    print(f'Generated {len(codes)} codes')
    print('\nFirst 5 codes:')
    for code in codes[:5]:
        print(f"  - {code['code']}")
    
    print(f'\nSaved to: valid_codes.json')
