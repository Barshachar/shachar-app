# Delivery Agent (Unified)

## ROLE
You are the single **Delivery Agent** for this repo. Your job: ship small, verifiable patches that keep `flutter analyze`, `flutter test -r compact`, and `scripts/qa-run.sh` green. Prefer UI/controller glue; only touch SQL when the task explicitly says so.

## DEFAULT GUARDRAILS
- **Do NOT** modify repositories/SQL unless the task says ALLOWED.
- Prefer **Keys** over text in tests (stable selectors).
- All strings go through **L10N** (assets/translations/*).
- RTL & a11y: no hard-coded direction; add `Semantics` where you touch controls.
- After any async op, guard with `if (!context.mounted) return;`.

## TASK TEMPLATE
- **CONTEXT**: 2–3 lines (what exists; where to hook)
- **ALLOWED FILES**: explicit paths
- **FORBIDDEN**: explicit (e.g., Repos/SQL)
- **TASKS**: bullet list (small steps)
- **ACCEPTANCE**: analyzer/test/qa + visible behavior
- **COMMANDS**:
  ```bash
  cd app
  flutter analyze && flutter test -r compact
  bash ./scripts/qa-run.sh    # only when required


DELIVERABLE: concise diff + STATUS (what changed, command results)

RUNBOOK

flutter analyze → fix lints.

flutter test -r compact → stabilize tests (use Keys).

If UI/E2E needed → bash ./scripts/qa-run.sh (handles Supabase + iOS sim).

If 429 rate-limit occurs, rely on AUTH_COOLDOWN_SEC and the retry wrapper already in qa-run.sh.

LOGGING & INSTRUMENTATION

Keep [NAV], [AUTH_FLOW] logs when touching auth/navigation.

Add stable ValueKey to new buttons/roots for tests and QA snapshots.

DONE = GREEN

A task is Done only if:

flutter analyze passes,

flutter test -r compact passes,

and (when requested) bash ./scripts/qa-run.sh ends PASS or WARN (429 only).


---

## מה הסוכן היחיד עושה עכשיו? (תור עבודה מיידי)

> המטרה: **להחזיר בדיקות לירוק**, ואז **לחבר UI ↔ SQL** בשלושה מסלולים (Pricing, Approvals, RFQ) ולסגור את ה‑MVP.

### Sprint A — ייצוב בדיקות (חובה לפני הכל)
**ALLOWED:**  
`apps/b2b_flutter/lib/src/features/customer/customer_home_page.dart`,  
`apps/b2b_flutter/lib/src/features/orders/presentation/checkout_page.dart`,  
`app/test/auth/login_page_test.dart`, `app/test/orders/checkout_page_test.dart`

**TASKS:**
1) להוסיף `ValueKey('customer_home_root')` לשורש `Scaffold` של Customer Home.  
2) לעדכן טסט דמו‑לוגין לחפש את המפתח הזה (במקום "Catalog Screen").  
3) להוסיף `ValueKey('checkout_submit_btn')` לכפתור שליחת הזמנה בצ’קאאוט ולעדכן הטסט לחפש לפי Key.

**ACCEPTANCE:**  
`flutter analyze && flutter test -r compact` ✅

### Sprint B — Pricing (UI/Service) ↔ SQL
**ALLOWED:**  
`apps/b2b_flutter/lib/src/features/pricing/**`,  
`apps/b2b_flutter/lib/src/features/catalog/presentation/**`,  
`app/assets/translations/*.arb`  
**FORBIDDEN:** Repos.

**TASKS:**
- Service קטן שקורא `rpc_resolve_price` (cache קצר בזיכרון).  
- עמוד מוצר: טבלת **Price Breaks** ל‑[MOQ, 2×, 5×] (ב‑try/catch → “—”).  
- קטלוג: תצוגת **מחיר אפקטיבי** + תג “מחיר חוזה” כשהמחיר שונה מבסיס.  
- בהוספה לסל: לציין מקור תמחור (Contract/PriceList/Base) בלוג/סנאקבר.

**ACCEPTANCE:**  
תמחור מוצג; `analyze/test` ירוק.

### Sprint C — Approvals (UI) ↔ SQL
**ALLOWED:**  
`apps/b2b_flutter/lib/src/features/approvals/presentation/**`, `apps/b2b_flutter/lib/src/features/orders/presentation/**`  
**TASKS:**  
- Checkout/Order‑Detail: באנר “ממתין לאישור” + “שלח לאישור” → `rpc_evaluate_approvals`.  
- Approver Inbox: רשימה + “אשר/דחה” → `rpc_approve_step`.  
- אחרי Approved: קונה רואה “אפשר ביצוע” וה‑Submit זמין.

**ACCEPTANCE:**  
מסלול דמה: הזמנה דורשת אישור → נשלחה → אושרה → Submit.

### Sprint D — RFQ/Quotes (UI) ↔ SQL
**ALLOWED:**  
`apps/b2b_flutter/lib/src/features/rfq/presentation/**`, `apps/b2b_flutter/lib/src/features/orders/presentation/**`  
**TASKS:**  
- “בקשת הצעת מחיר” מהעגלה/מוצר → `rpc_create_rfq`.  
- Vendor Quote form → `rpc_vendor_submit_quote`.  
- Customer Accept → `rpc_customer_accept_quote` (יוצר order draft) → ניווט ל‑Order‑Detail.

**ACCEPTANCE:**  
מסלול דמה: RFQ → Quote → Accept → Draft נוצר ומוצג.

---

## למה סוכן אחד עכשיו עדיף?
- אין קפיצות הקשר/קבצים בין סוכנים;  
- פחות התנגשויות במבנה/בדיקות;  
- קל “לסגור לולאה” של analyze/test/qa בכל איטרציה.

אעדכן אותך בהתאם לביצוע הסוכן – אבל כבר עכשיו יש לך את כל הטקסטים להדבקה (כולל קובץ ההנחיות).  
אם תרצה, אכין גם **PROJECT_STATE.md** מעודכן (טבלה קצרה שממפה את סעיפים ‎1–22 למסמך שלך למצב/חסמים/הבא בתור).

**סיכום קצר:**  
- **MVP** ~**60–65%**.  
- **תכנית מלאה** ~**40–45%**.  
עם הסוכן היחיד ותרחיש הסְפְרינטים למעלה, ההשלמה הקרובה ביותר ל‑MVP תגיע דרך **ייצוב טסטים → Pricing UI → Approvals → RFQ**, כשבמקביל ה‑QA/CI כבר מקשיח 429 ורץ.
