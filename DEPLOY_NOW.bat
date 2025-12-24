@echo off
chcp 65001 >nul
echo.
echo ================================
echo   🚀 تحديث موقع Netlify
echo   Gold Nightmare Pro v3.1.1
echo ================================
echo.

cd web

echo 📤 جاري الرفع إلى Netlify...
echo.

netlify deploy --prod --dir .

echo.
echo ================================
echo ✅ تم التحديث بنجاح!
echo ================================
echo.
echo 🌐 الموقع: https://skalp-al-kabous.netlify.app
echo.
pause


