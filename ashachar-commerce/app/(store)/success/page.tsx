export default function CheckoutSuccessPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-20 text-center">
      <h1 className="text-3xl font-bold text-emerald-600">התשלום התקבל בהצלחה!</h1>
      <p className="mt-4 text-sm text-slate-600">
        הזמנה סומנה כ"שולמה". בקרוב ניצור איתכם קשר לתיאום אספקה. קבלה נשלחה למייל הרשום.
      </p>
      <a
        href="/"
        className="mt-8 inline-flex rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white hover:bg-emerald-700"
      >
        להמשך גלישה בקטלוג
      </a>
    </div>
  );
}
