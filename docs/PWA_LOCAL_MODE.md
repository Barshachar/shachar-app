# PWA Local Mode

ה־PWA נועד לשמש הדגמה ללא גישה לנתונים אמיתיים. לכן חלים הכללים הבאים:

1. משתנה הסביבה `APP_DATA_MODE` חייב להיות `local`. בקשות שאינן תחת `/app/api/admin/**` או `/app/admin/**` ייחסמו ב־403 אם הוא שונה.
2. כל API שאינו אדמין מריץ `assertLocalMode()` בתחילת ה־handler (כולל cart, checkout, webhooks, quote וכו').
3. כל ספריית Data (`cart-db.ts`, `data.ts`, `local-store.ts`) משתמשת אך ורק בקבצי JSON מקומיים; אין יצירת Supabase Client בצד Buyer.
4. Layout מציג באנר “Demo / Local Data Only” כדי למנוע בלבול אצל משתמשים.
5. בדיקות Vitest (`tests/api-local-mode.test.ts`) מבטיחות שכל API רגיל זורק 503/403 במצב remote.
6. CI מריץ `pnpm -C apps/web_pwa typecheck` ו־`pnpm test` כך שאי־ציות למצב local יפיל את ה־pipeline.
