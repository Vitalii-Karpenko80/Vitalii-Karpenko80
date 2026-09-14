#!/bin/bash
echo "🚀 Перенос Mindy в новый репозиторий..."
echo ""

git clone https://github.com/Vitalii-Karpenko80/Vitalii-Karpenko80.git mindy-temp
cd mindy-temp
git checkout cursor/voice-pocket-app-552d
git remote remove origin
git remote add origin https://github.com/Vitalii-Karpenko80/Mindy.git
git push -u origin cursor/voice-pocket-app-552d:main
cd ..
rm -rf mindy-temp

echo ""
echo "✅ Готово! Репозиторий: https://github.com/Vitalii-Karpenko80/Mindy"
