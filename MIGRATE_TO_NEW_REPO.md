# Перенос Mindy в новый репозиторий

## 🚀 Быстрый способ (рекомендуется)

Выполните эти команды в терминале на вашем компьютере:

```bash
# 1. Клонируйте текущий репозиторий
git clone https://github.com/Vitalii-Karpenko80/Vitalii-Karpenko80.git mindy-temp
cd mindy-temp

# 2. Переключитесь на ветку с кодом Mindy
git checkout cursor/voice-pocket-app-552d

# 3. Удалите старый remote
git remote remove origin

# 4. Добавьте новый репозиторий как origin
git remote add origin https://github.com/Vitalii-Karpenko80/Mindy.git

# 5. Запушьте код в main ветку нового репозитория
git push -u origin cursor/voice-pocket-app-552d:main

# 6. Готово! Можете удалить временную директорию
cd ..
rm -rf mindy-temp
```

## 📦 Альтернативный способ (чистая история)

Если хотите начать с чистой истории коммитов:

```bash
# 1. Клонируйте новый пустой репозиторий
git clone https://github.com/Vitalii-Karpenko80/Mindy.git
cd Mindy

# 2. Скопируйте все файлы из старого репозитория
# (замените PATH_TO_OLD_REPO на путь к клонированному выше репозиторию)
cp -r ../mindy-temp/* .
cp -r ../mindy-temp/.gitignore .

# 3. Удалите index.html (если он не нужен)
rm -f index.html

# 4. Создайте начальный коммит
git add -A
git commit -m "feat: Initial commit - Mindy v1.1

🧠 Mindy — AI Thought Companion

✨ Возможности:
- Голосовой ввод с распознаванием речи
- GPT-4 парсинг задач
- Аналитика и инсайты
- iCloud синхронизация
- Интеграции (Telegram, Email, Calendar)
- iOS 2026 Design Language
- Liquid Glass UI

📊 Статистика:
- 18 Swift файлов
- ~8000 строк кода
- 5 основных сервисов
- 9 интеграций

💰 Freemium модель: 299₽/мес"

# 5. Запушьте в main
git push -u origin main
```

## 🎯 Что делать дальше

После успешного переноса:

1. **Обновите README.md** - проверьте, что все ссылки работают
2. **Добавьте темы (topics)** в настройках репозитория:
   - `ios`
   - `swift`
   - `swiftui`
   - `gpt-4`
   - `voice-recognition`
   - `productivity`
   - `ai`
   - `cloudkit`

3. **Настройте GitHub Pages** (опционально):
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: main, folder: / (root)

4. **Добавьте скриншоты**:
   - Создайте папку `Screenshots/`
   - Добавьте скриншоты приложения
   - Обновите README.md

5. **Создайте Release**:
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0 - Premium Features"
   git push origin v1.1.0
   ```

## ✅ Проверка

После переноса убедитесь что:
- [ ] Весь код доступен в новом репозитории
- [ ] README отображается корректно
- [ ] LICENSE файл на месте
- [ ] .gitignore настроен правильно
- [ ] Все файлы и папки перенесены

## 🔗 Полезные ссылки

- Новый репозиторий: https://github.com/Vitalii-Karpenko80/Mindy
- Старый PR: https://github.com/Vitalii-Karpenko80/Vitalii-Karpenko80/pull/3

---

**Если возникнут проблемы**, напишите мне!
