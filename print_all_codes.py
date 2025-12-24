import json

# قراءة الأكواد
with open('valid_codes.json', 'r', encoding='utf-8') as f:
    codes = json.load(f)

# كتابة كل الأكواد
with open('../ALL_100_CODES.txt', 'w', encoding='utf-8') as f:
    f.write('=' * 60 + '\n')
    f.write('   GOLDEN NIGHTMARE PRO V3 - ALL 100 ACTIVATION CODES\n')
    f.write('=' * 60 + '\n\n')
    f.write(f'Total Codes: {len(codes)}\n')
    f.write('Validity: 30 Days Each\n')
    f.write('Expiry Date: 2026-01-12\n\n')
    f.write('=' * 60 + '\n\n')
    
    for i, code_data in enumerate(codes, 1):
        f.write(f'{i:3d}. {code_data["code"]}\n')
    
    f.write('\n' + '=' * 60 + '\n')
    f.write('\nSUPPORT:\n')
    f.write('Telegram: @Odai_xau (https://t.me/Odai_xau)\n')
    f.write('WhatsApp: +962786275654\n')
    f.write('=' * 60 + '\n')

print(f'Done! Exported {len(codes)} codes to ALL_100_CODES.txt')
