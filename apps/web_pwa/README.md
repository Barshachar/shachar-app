# א.שחר – מצב מקומי בלבד

## Local-Only Production
- Build locally: `npm run build && PORT=3000 npm run start`
- Docker build: `docker build -t ashachar-local .`
- Docker run (persistent data): `docker run --rm -p 3000:3000 -v $(pwd)/data:/app/data ashachar-local`

> שימו לב: המערכת כותבת אל תוך תיקיית `data/`, לכן נדרש קובץ מערכת עם הרשאות כתיבה (שרת פרטי, VM, או Docker עם ווליום משותף).

## SEO
- Endpoints: `/robots.txt` ו-`/sitemap.xml` נבנים מקומית לפי קבצי `data/*.json`.
- קאנוניקל: הפונקציה `canonical()` בונה כתובת מלאה על בסיס `NEXT_PUBLIC_SITE_URL` (ברירת מחדל: `http://localhost:3003`).
- JSON-LD: הבית כולל Organization + WebSite, קטגוריות עם BreadcrumbList, ומוצר עם Product + Breadcrumb.
- Social OG: `/api/og` מייצר תמונת 1200×630 לשיתוף (`title`, `subtitle`, `badge`).
- לפריסה בדומיין אמיתי הגדירו `NEXT_PUBLIC_SITE_URL=https://your-domain` כדי לעדכן קאנוניקל, sitemap ו-OG.

## Importing real CSV
- הריצו `npm run import:csv -- <path>` כדי להטעין קטלוג מקומי. לפני כל כתיבה נשמר גיבוי ב-`data/backup/`.
- מצב תצוגה מקדימה: `npm run import:csv -- --dry-run fixtures/supplier.csv` (ללא שינוי קבצים).
- סכמות נתמכות:
  - **Canonical (EN):** `name,slug,sku,brand,category_slug,price_cents,primary_image_url,description_html`.
  - **Supplier (HE):** `"שם מוצר","מקט","מותג","קטגוריה","מחיר (₪)","תמונה","תיאור"` (slug וקטגוריה נבנים אוטומטית).
- הממפה מתמודד עם ערכי מחיר כגון `299.90`, `1,234.50`, `1.234,50` וממיר לשקלים באגורות באמצעות `Math.round(value * 100)`.
- דוגמה:

```csv
"שם מוצר","מקט","מותג","קטגוריה","מחיר (₪)","תמונה","תיאור"
"ברז יוקרתי","BZ-123","חמת","ברזים","299.90","https://cdn.example.com/tap.jpg","<p>ברז יוקרה</p>"
"מפצל צנרת","MF-001","פלסאון","אביזרי צנרת","1,234.50","","<p>אביזר לחץ</p>"
"צינור תקול","BAD-000","ספק","ללא","","","<p>חסרה עלות</p>"
```
- פלט הפקודה מציג שורות עובדות/נכשלות, סטטיסטיקות (added/updated/skipped) והודעות שגיאה פר-שורה.

## Admin PIN & Read-only
- צרו קובץ `.env.local` והוסיפו `ADMIN_PIN=1234` (בחרו PIN חזק).
- התחברות: פתחו `/admin/login`, הזינו את ה-PIN, והמערכת תשמור עוגיה `admin_pin` (HttpOnly, SameSite=Lax).
- כדי לאפשר למנהלים רק צפייה, הגדירו `ADMIN_READONLY=1`. במצב זה כל בקשות POST/PUT/DELETE (כולל יצירת גיבוי) נחסמות בצד השרת וה-UI מציג הודעת קריאה בלבד.
- מזכיר: ממשק הניהול נשאר Local-Only ונגיש רק כאשר `APP_DATA_MODE=local`.
