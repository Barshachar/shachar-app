# Invariants (מחייב)

1. בידוד טננט – כל טבלה מרובת-חברות מוגנת על־ידי RLS, פונקציות שולחות `auth_company_id()` ומבחני SQL מאשרים שאין דליפות.
2. הגשת הזמנות מתבצעת **רק** דרך `rpc_submit_order`; היא ממלאת מחירים, מעדכנת סטטוסים ורושמת Audit.
3. אין שימוש במפתחות service-role בזרימות Buyer או ב־PWA; CI מפיל PR שמפר זאת.
4. מצב ה־PWA הוא Local-Only: APIs לא אדמין מחזירים 403 כאשר `APP_DATA_MODE` שונה, והמידלוור סוגר בקשות מוקדם.
5. כל אירוע פיננסי/סטטוס נרשם בטבלת `audit_log` עם `actor_user_id` ופרטי טננט.
6. Edge Functions מריצות בדיקת תפקידים (system/vendor admin) ובדיקה שה־company_id המבוקש תואם ל־JWT.
7. חבילות contracts מגדירות DTOs יחידות מקור לסכימת Supabase; Flutter/PWA משתמשים בהן.
8. Offline Queue מריצה פעולות רק עבור ה־tenant האקטיבי ומשמרת תורים נפרדים לכל טננט.
9. Price Lists / Prices נגישים ל־Vendor רק עבור `vendor_company_id` שלהם, ולקוחות רואים רק רשומות scope=customer אליהם.
10. יבוא מחירים (`price_lists_import`) תמיד שולח RPC עם מזהה Vendor שהתקבל, ומבחן Deno מבטיח זאת.
11. Webhook תשלום (Cardcom) אידמפוטנטי: כל `TrxId` מעודכן פעם אחת בלבד.
12. Cart / Checkout / Web APIs משתמשים ב־local-store בלבד; אין גישות PostgREST/Realtime בצד Buyer.
13. Flutter Admin Repository מדבר רק דרך פונקציית Edge אחת וממשיך לתמוך ב־offline queue.
14. Guard-rails ב־CI מריצים Vitest, Flutter, SQL ו־Deno במטרה לאמת קונטרקטים, רולים וטסטים קריטיים.
15. `supabase/sql/schema.sql` ו־`schema_applied.sql` נשארים מקור אמת; כל patch מעדכן את שניהם ומקבל בדיקות SQL.
16. כל שינוי שמחייב Edge/SQL מוסיף בדיקה רלוונטית (RLS, RPC, Price Import, Webhook, Offline).
17. מדריכי Docs (Local Mode, Operations, Invariants) חייבים להיות מעודכנים כדי לאפשר אופרציה מהירה לצוותים.
18. אין גישה ישירה ל־Supabase מתוך Widgets; Flutter עובד דרך repositories בלבד (בדיקת CODEOWNERS מגינה על כך).
19. הזדהות אדמין ל־Edge מתבצעת עם JWT בלבד; אין חלופות אנונימיות ואין הרצה של invite/set-role ללא scope.
20. חוזים משותפים (contracts) נבנים (`pnpm -C packages/contracts build`) לפני שימוש, ו־CI מריץ את ה־Vitest שלהם.
