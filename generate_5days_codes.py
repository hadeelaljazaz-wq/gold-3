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

def generate_codes(count, days):
    """Generate activation codes"""
    codes = []
    now = datetime.now()
    expiry = now + timedelta(days=days)
    
    for _ in range(count):
        code = {
            "code": generate_code(),
            "days": days,
            "expiry_date": expiry.isoformat(),
            "status": "active",
            "created_at": now.isoformat()
        }
        codes.append(code)
    
    return codes

# Generate 50 codes for 5 days
codes_5days = generate_codes(50, 5)

# Save to JSON file
with open('valid_codes_5days.json', 'w', encoding='utf-8') as f:
    json.dump(codes_5days, f, indent=2, ensure_ascii=False)

print(f"✅ تم إنشاء {len(codes_5days)} كود لمدة 5 أيام")
print(f"📅 صالح حتى: {codes_5days[0]['expiry_date'][:10]}")
print(f"\nأول 5 أكواد:")
for i, code in enumerate(codes_5days[:5], 1):
    print(f"  {i}. {code['code']}")
