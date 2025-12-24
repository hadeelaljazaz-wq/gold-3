import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('valid_codes_3days.json', 'r', encoding='utf-8') as f:
    codes = json.load(f)

print("=" * 70)
print("   20 Trial Codes - Valid for 3 Days Only")
print(f"   Expires on: {codes[0]['expiry_date'].split('T')[0]}")
print("=" * 70)
print()

for i, code_data in enumerate(codes, 1):
    print(f"{i:2d}. {code_data['code']}")

print()
print("=" * 70)
print("Note: These codes are for trial - expires after 3 days!")
print("=" * 70)
