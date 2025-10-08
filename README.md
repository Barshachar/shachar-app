# א.שחר Marketplace Monorepo

Monorepo עבור פלטפורמת ה-B2B/B2C של "א.שחר" הכולל את אפליקציית Flutter, ה-Web PWA ב-Next.js, סכימת Supabase וכלי תפעול.

## מבנה הריפו
```
apps/
  b2b_flutter/        # אפליקציית Flutter (מובייל + Flutter Web Admin)
  web_pwa/            # Next.js 14 Storefront & Admin PWA
packages/
  dart/design_system/ # קומפוננטים משותפים ל-Flutter
  dart/offline_toolkit/# Offline-first primitives (Hive/Drift/Workmanager)
  ts/web_ui/          # OG image template ו-UI משותף לצד ה-Web
supabase/
  sql/                # סכימה, מדיניות RLS ו-Patches
  functions/          # Edge Functions (Deno)
  tests/              # רגרסיות RLS (psql)
  environments/       # overrides (למשל staging)
tools/
  qa/                 # סקריפטים ל-QA ו-Simulator
  ci/                 # סקריפטי CI
  snapshots/          # לכידת מצבים (ts-node)
  imports/            # כלי CLI לייבוא (עם לוגים)
docs/                 # ADRs, ERD, Offline, Architecture & Security Reports
codex/                # דוחות אוטומטיים (AUDIT, SECURITY, EXECUTION)
```

## דרישות מוקדמות
- Flutter 3.16+ (channel stable) + Xcode/Android SDK לפי צורך
- Node.js 20+
- Deno 1.46+ (Edge Function tests)
- Supabase CLI (אופציונלי לניהול DB מקומי)

---

## הפעלת האפליקציות

### Flutter — `apps/b2b_flutter`
```bash
cd apps/b2b_flutter
flutter pub get
flutter run   # או flutter build web --release
```
משתני סביבת Flutter נשמרים ב-`.env.json`. הקפידו להגדיר URL ו-Key של Supabase, וערכי demo ל-auth (לבדיקות מקומיות). 

`offline_toolkit` מספק cache + sync queue. לצורך smoke tests:
```bash
flutter test test/smoke/app_smoke_test.dart
```

#### Widget Tests & Harness
- עטפו ווידג'טים ב-`makeTestApp` (`test/test_harness.dart`) כדי לקבל `ProviderScope`, `MaterialApp.router` עם GoRouter מינימלי ותמיכה ב-RTL/i18n.
- ניתן להוסיף overrides דרך הפרמטר `overrides` ולצרף delegate-ים נוספים באמצעות `extraDelegates`.
- לשירותי תמחור/קטלוג השתמשו ב-`FakePriceResolutionService` ו-`FakeCatalogRepository` מתוך `test/fakes/` כדי למנוע גישות ל-Supabase בזמן הרצה.

### Next.js PWA — `apps/web_pwa`
```bash
cd apps/web_pwa
npm ci
npm run dev          # dev server על 3003
npm run lint         # Next lint
npm test             # Vitest (כולל smoke + RLS policies)
npm run build
```
העתיקו `.env.example` ל-`.env.local` והגדירו מפתחות Supabase ו-Cardcom.

---

## Supabase
1. פריסה ידנית:
   ```bash
   psql "$SUPABASE_DB" -f supabase/sql/schema.sql
   psql "$SUPABASE_DB" -f supabase/sql/policies.sql
   psql "$SUPABASE_DB" -f supabase/seed.sql
   ```
2. רגרסיות RLS:
   ```bash
   psql "$SUPABASE_DB" -f supabase/tests/rls_regressions.sql
   ```
   התסריט מאשש שוונדורים/לקוחות אינם חוצים tenants.
3. Edge Functions (Deno):
   ```bash
   deno task deploy # או supabase functions deploy <name>
   deno test supabase/functions
   ```

---

## כלי CLI
- `tools/qa/qa-run.sh` – הרצה מלאה של בדיקות Flutter + סימולציות.
- `tools/imports/catalog_delta_import.mjs` – סריקת CSV לייבוא קטלוג, כתיבת סיכום ל-`logs/imports/`:
  ```bash
  node tools/imports/catalog_delta_import.mjs --input path/to/catalog.csv
  ```
- `tools/snapshots/*` – לכידת מסכי Web/Flutter דרך ts-node.

---

## CI
קובץ Workflow חדש: `.github/workflows/ci.yml`
- **Flutter**: `flutter pub get`, `flutter analyze`, `flutter test` בתוך `apps/b2b_flutter`.
- **Web PWA**: `npm ci`, `npm run lint`, `npm test` בתוך `apps/web_pwa`.
- **Edge Functions**: `deno test supabase/functions`.

---

## תיעוד נוסף
- `docs/ARCHITECTURE_REVIEW.md` – סקירת ארכיטקטורה (Flutter + Supabase) + TODOs.
- `codex/SECURITY_REPORT.md` – מצב RLS + המלצות.
- `docs/offline.md` – אסטרטגיית Offline-first וחיבורים ל-`offline_toolkit`.
- `docs/ADRs/` – החלטות ארכיטקטורה (Flutter Web Admin, Clean Architecture וכו').

תרומות: פתחו Branch, הריצו את ה-CI הלוקלי (`flutter test`, `npm test`, `deno test`), ודאגו להוסיף בדיקות/תיעוד לפי הצורך.
