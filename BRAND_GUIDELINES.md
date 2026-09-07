# Mindy Brand Guidelines 🧠

## Brand Identity

### Name
**Mindy** — от "Mind" (разум) + уменьшительное "-y"

### Tagline
**"Your AI Thought Companion"**

Alternative taglines:
- "Think out loud. Mindy remembers."
- "Your personal mind assistant"
- "Capture thoughts instantly"

### Brand Promise
> Mindy никогда не забывает ваши мысли и превращает их в действия.

---

## Visual Identity

### Logo Concept

**Primary Icon**: 🧠 Brain / Head Profile
- SF Symbol: `brain.head.profile`
- Ассоциация с разумом, мышлением, AI

**Alternative**: 💭 Thought Bubble
- Для более дружелюбного стиля

### Color Palette

#### Primary Colors
```
Cyber Blue    #66CCFF    RGB(102, 204, 255)
Purple        #CC66FF    RGB(204, 102, 255)
```

#### Secondary Colors
```
Pink          #FF80B3    RGB(255, 128, 179)
Deep Dark     #0D0D1F    RGB(13, 13, 31)
```

#### Text Colors
```
Primary       #FFFFFF    100% white
Secondary     #FFFFFF    70% opacity
Tertiary      #FFFFFF    40% opacity
```

#### Gradients
```swift
// Primary gradient
LinearGradient(
    colors: [.cyberBlue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

---

## Typography

### Font Family
**San Francisco Rounded**

### Hierarchy
- **Display**: 48pt, Bold — главные заголовки
- **Title 1**: 32pt, Semibold — секции
- **Title 2**: 24pt, Semibold — подзаголовки
- **Body**: 17pt, Regular — основной текст
- **Caption**: 13pt, Medium — подписи

### Line Spacing
- Display: 52pt (1.08x)
- Title: 36pt/28pt
- Body: 22pt (1.29x)
- Caption: 16pt

---

## Voice & Tone

### Personality Traits
- 🧠 **Умная** — понимает контекст, разговаривает естественно
- 💬 **Дружелюбная** — как персональный помощник, не робот
- ⚡ **Эффективная** — быстрые ответы, без лишних слов
- 🎯 **Помогающая** — всегда на стороне пользователя

### Voice Examples

✅ **Правильно:**
- "Готово! Напоминание создано."
- "Не могу распознать дату. Попробуйте ещё раз?"
- "Ваша мысль сохранена 🧠"

❌ **Неправильно:**
- "Операция выполнена успешно." (слишком формально)
- "Ошибка 404: дата не найдена." (слишком техническ)
- "OK" (слишком сухо)

---

## UI/UX Principles

### Design Language
**iOS 2026** — Liquid Glass, Springy Animations, Soft Depth

### Core Interactions
1. **Tap** → Springy animation (scale 0.95)
2. **Swipe** → Reveal actions
3. **Long press** → Details
4. **Haptic feedback** → Medium impact on actions

### Animation Guidelines
- **Duration**: 0.3-0.4s для transitions
- **Curve**: Spring (response: 0.3, damping: 0.6-0.7)
- **Scale effects**: 0.9-0.95 для pressed state

---

## Iconography

### Primary Icon
🧠 **brain.head.profile** — главный символ приложения

### Type Icons
- 📞 **phone.fill** — Call
- 👥 **person.2.fill** — Meeting
- 🛒 **cart.fill** — Purchase
- 🔔 **bell.fill** — Reminder
- 📝 **note.text** — Note
- ✅ **checkmark.circle.fill** — Task

### Priority Indicators
- 🔴 High — красный круг
- 🟡 Medium — жёлтый круг
- 🟢 Low — зелёный круг

### SF Symbols Style
- **Weight**: Regular to Semibold
- **Rendering**: Multicolor или Hierarchical
- **Size**: 16-24pt для UI элементов

---

## Copy Guidelines

### App Store

**Title**: Mindy - AI Thought Companion

**Subtitle**: Voice-powered task capture with GPT-4

**Description**:
```
Mindy — ваш персональный разум-помощник, который никогда не забывает.

✨ Просто скажите, что у вас на уме
🧠 Mindy понимает контекст с GPT-4
✅ Автоматически создаёт задачи
📅 Распознаёт любые форматы дат
🎯 Определяет приоритеты

Одна кнопка. Ваш голос. Полная организация.

ВОЗМОЖНОСТИ:
• Голосовой ввод на русском языке
• GPT-4 интеграция для умного парсинга
• Автоматическое создание напоминаний
• Lock Screen Widget для быстрого доступа
• Action Button support (iPhone 15 Pro)
• Siri Shortcuts integration
• Красивый дизайн iOS 2026

Think out loud. Mindy remembers.
```

### Permission Requests

**Microphone**:
"Mindy использует микрофон для записи ваших мыслей голосом"

**Speech Recognition**:
"Mindy преобразует вашу речь в текст для создания задач"

**Reminders**:
"Mindy создаёт напоминания, чтобы вы ничего не забыли"

---

## Marketing

### Key Messages

1. **Мгновенный захват мыслей**
   > Не теряйте идеи. Просто скажите — Mindy запомнит.

2. **AI понимает контекст**
   > GPT-4 извлекает задачи, даты и приоритеты автоматически.

3. **Всегда под рукой**
   > Lock Screen Widget, Action Button, Siri — доступ за секунду.

### Target Audience

**Primary**: 
- Возраст: 25-45
- Профессионалы, предприниматели
- iOS power users
- Люди с активным образом жизни

**Secondary**:
- Студенты
- Креативщики
- Tech early adopters

### Use Cases

1. **В дороге**
   "В метро вспомнили важную мысль? Mindy запишет за 3 секунды"

2. **На встрече**
   "Клиент сказал что-то важное? Быстро зафиксируйте в Mindy"

3. **Перед сном**
   "Мысли не дают уснуть? Выгрузите их в Mindy"

4. **Во время работы**
   "Action Button + голос = мгновенная запись без отвлечения"

---

## Social Media

### Profile Bio
```
🧠 Your AI thought companion
⚡ Voice → Task in seconds
🎨 Beautiful iOS 2026 design
🧠 Powered by GPT-4
```

### Hashtags
```
#Mindy #AIAssistant #ProductivityApp
#VoiceFirst #iOS2026 #GPT4
#ThoughtCapture #MindApp
```

### Content Pillars
1. **Product demos** (40%) — показываем возможности
2. **Tips & tricks** (30%) — как использовать эффективно
3. **User stories** (20%) — реальные кейсы
4. **Behind the scenes** (10%) — процесс разработки

---

## Community

### Support Tone
- Эмпатичный
- Быстрый
- Решение-ориентированный

### Example Response
```
User: "Не работает GPT-4 парсинг"

Mindy Support:
"Привет! 👋 Давайте разберёмся:
1. API ключ добавлен в настройках?
2. На балансе OpenAI есть средства?
3. Интернет подключён?

Напишите, что из этого уже проверили, и я помогу дальше! 🧠"
```

---

## Brand Don'ts

❌ **Не делайте:**
- Использовать "я" от лица приложения
- Называть пользователя "юзером"
- Техническую терминологию без объяснений
- Обещать то, что не работает
- Сравнивать с конкурентами негативно

✅ **Делайте:**
- Говорить "мы" когда про команду
- Называть "вы" или по имени
- Объяснять простым языком
- Быть честными о limitations
- Фокус на уникальных преимуществах

---

## Evolution

### Version History
- **v1.0** (2026) — Launch с iOS 2026 design + GPT-4
- **v1.1** (planned) — Multi-language, Apple Watch
- **v1.2** (planned) — macOS, iCloud sync

### Future Considerations
- Персонаж-маскот Mindy
- Анимированные переходы между экранами
- Voice personality для Siri integration
- AR элементы для visionOS

---

## Resources

### Design Assets
- SF Symbols: brain.head.profile
- Color palette: [Color swatches]
- Typography: San Francisco Rounded

### Templates
- App Store screenshots template
- Social media post template
- Email signature template

---

**Brand Guidelines v1.0**  
Last updated: September 7, 2026  
Maintained by: Vitalii Karpenko

*Эти guidelines живой документ. Обновляйте по мере эволюции бренда.*
