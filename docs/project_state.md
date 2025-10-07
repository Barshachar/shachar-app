# Project State — Single Source of Truth
_last updated: <YYYY‑MM‑DD HH:MM> by <owner>_

> מסמך זה הוא אמת יחידה. כל שינוי במצב/החלטה/קבלה מתועדים כאן.
> סוכנים: אל תיגעו בפריטים תחת **🟢 DONE**. עבדו רק על **🟡 VERIFY** או **🔴 OPEN**.

---

## מקרא (Legend)
- 🔴 OPEN – לא הוחל / שבור / חסר.
- 🟡 VERIFY – פותח; דרושה בדיקת QA ידנית או צילום מסך/לוג.
- 🟢 DONE – הושלם, יש ראיות (בדיקות/צילומים/לוגים); אין לגעת.
- ⚪ N/A – מחוץ לסקופ הגרסה הנוכחית.

Priorities: **P0** (קריטי), **P1** (חשוב), **P2** (שיפור).

ראיות:  
• **Screens**: `docs/screens/*.png`  
• **Logs**: `/tmp/qa-run.log` (QA), `/tmp/ws-diagnose.log` (white-screen)  
• **Tests**: `flutter test -r compact` תקין

---

## סביבת ריצה / Runbook קצר
```
bash
cd app
flutter clean && flutter pub get
flutter analyze && flutter test -r compact
# QA מלאה (שומרת צילומים ולוגים; עם הגנות Rate‑Limit):
bash ./scripts/qa-run.sh
# אם ה‑driver נתקע ב‑product checkout:
QA_SKIP_PRODUCT_CHECKOUT=1 bash ./scripts/qa-run.sh
```
