# Build Commands

## Prerequisites
- Docker running locally
- Supabase CLI installed (`brew install supabase/tap/supabase`)
- Flutter 3.22+ (`flutter --version`)

## Supabase
```bash
supabase start
supabase db reset --schema-file supabase/sql/schema.sql --seed-file supabase/seeds/seed.sql
```

## Flutter (Web + Mobile)
```bash
cd app
flutter pub get
flutter analyze
flutter test --coverage
flutter build web --release
flutter build apk --debug
```

Scripts: see `supabase/scripts/` for automated variants.
