import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('assets/valid_codes.json', 'r', encoding='utf-8') as f:
    codes = json.load(f)

days_30 = [c for c in codes if c['days'] == 30]
days_3 = [c for c in codes if c['days'] == 3]

print("=" * 60)
print("تحقق من الأكواد في التطبيق")
print("=" * 60)
print(f"\nإجمالي الأكواد: {len(codes)}")
print(f"أكواد 30 يوم: {len(days_30)}")
print(f"أكواد 3 أيام: {len(days_3)}")

if days_3:
    print(f"\nأكواد 3 أيام تنتهي في: {days_3[0]['expiry_date'].split('T')[0]}")
if days_30:
    print(f"أكواد 30 يوم تنتهي في: {days_30[0]['expiry_date'].split('T')[0]}")

print("\n" + "=" * 60)
print("جاهز للبناء!")
print("=" * 60)
