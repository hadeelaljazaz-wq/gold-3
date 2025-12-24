import json
import random
import string
from datetime import datetime, timedelta

def generate_code_4parts():
    """Generate activation code with 4 parts (not 5!)"""
    parts = []
    for _ in range(3):  # 3 parts of random characters
        part = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
        parts.append(part)
    return 'GNP-' + '-'.join(parts)

def generate_codes(count, days, code_type='standard'):
    """Generate activation codes"""
    codes = []
    now = datetime.now()
    expiry = now + timedelta(days=days)
    
    for _ in range(count):
        code_data = {
            "code": generate_code_4parts(),
            "days": days,
            "expiry_date": expiry.isoformat(),
            "status": "active",
            "created_at": now.isoformat()
        }
        
        if code_type == 'lifetime':
            code_data["type"] = "lifetime"
            
        codes.append(code_data)
    
    return codes

# Generate 100 codes for 30 days
print("🔄 Generating 30-day codes (100 codes)...")
codes_30days = generate_codes(100, 30)
with open('assets/activation_codes/valid_codes.json', 'w', encoding='utf-8') as f:
    json.dump(codes_30days, f, indent=2, ensure_ascii=False)
print(f"✅ Created {len(codes_30days)} codes for 30 days")
print(f"   Example: {codes_30days[0]['code']}")

# Generate 50 codes for 5 days
print("\n🔄 Generating 5-day codes (50 codes)...")
codes_5days = generate_codes(50, 5)
with open('assets/activation_codes/valid_codes_5days.json', 'w', encoding='utf-8') as f:
    json.dump(codes_5days, f, indent=2, ensure_ascii=False)
print(f"✅ Created {len(codes_5days)} codes for 5 days")
print(f"   Example: {codes_5days[0]['code']}")

# Generate 10 lifetime codes (100 years)
print("\n🔄 Generating lifetime codes (10 codes)...")
codes_lifetime = generate_codes(10, 36500, 'lifetime')
with open('assets/activation_codes/valid_codes_lifetime.json', 'w', encoding='utf-8') as f:
    json.dump(codes_lifetime, f, indent=2, ensure_ascii=False)
print(f"✅ Created {len(codes_lifetime)} lifetime codes")
print(f"   Example: {codes_lifetime[0]['code']}")

print(f"\n🎉 Total codes generated: {len(codes_30days) + len(codes_5days) + len(codes_lifetime)}")
print("\n📝 All codes now have 4 parts format: GNP-XXXX-XXXX-XXXX")
