import json
import random
import string
from datetime import datetime, timedelta

def generate_code():
    """Generate a random activation code in format GNP-XXXX-XXXX-XXXX"""
    parts = []
    for _ in range(4):
        part = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
        parts.append(part)
    return 'GNP-' + '-'.join(parts)

def generate_lifetime_codes(count):
    """Generate lifetime activation codes"""
    codes = []
    now = datetime.now()
    # تاريخ انتهاء بعيد جداً (100 سنة من الآن)
    expiry = now + timedelta(days=36500)  # ~100 years
    
    for _ in range(count):
        code = {
            "code": generate_code(),
            "days": 36500,  # مدى الحياة (100 سنة)
            "expiry_date": expiry.isoformat(),
            "status": "active",
            "created_at": now.isoformat(),
            "type": "lifetime"
        }
        codes.append(code)
    
    return codes

# Generate 10 lifetime codes
codes_lifetime = generate_lifetime_codes(10)

# Save to JSON file
with open('valid_codes_lifetime.json', 'w', encoding='utf-8') as f:
    json.dump(codes_lifetime, f, indent=2, ensure_ascii=False)

print(f"✅ تم إنشاء {len(codes_lifetime)} كود مدى الحياة")
print(f"📅 صالح حتى: {codes_lifetime[0]['expiry_date'][:10]}")
print(f"\n🌟 جميع الأكواد (10 أكواد):")
for i, code in enumerate(codes_lifetime, 1):
    print(f"  {i}. {code['code']}")
