## תקציר
מה משתנה ולמה.

## סיכון / אינוואריאנטים
- [ ] אין שימוש service-role בזרימות Buyer
- [ ] RLS לא הוחלשה
- [ ] סכומים/סטטוסים משתנים רק דרך RPC

## SQL/Edge
קבצים/מיגרציות/השפעות, ו-Rollback.

## בדיקות
- יחידה:
- אינטגרציה (SQL/Edge):
- ידניות:

## איך בדקתי מקומית
פקודות/תרחישים.
- `DATABASE_URL=postgres://user:pass@host:5432/db bash .ci/guard-typegen-ts.sh`
