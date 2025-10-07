# Automation Selector Map

Stable widget keys for QA automation. Keys are exposed either directly on the widget or on a wrapping `Semantics` node when multiple instances exist.

## Saved Lists
- `saved_list_root` – page scaffold wrapper.
- `saved_list_add_all_btn` – semantics wrapper for the Add All button in each card (button keeps unique `saved_list_add_all_btn_<listId>` key).
- `saved_list_add_all_result_snackbar` – snackbar surfaced after Add All.

## Reorder
- `reorder_add_all_btn` – Add All button in footer.
- `reorder_add_all_result_snackbar` – snackbar surfaced after Add All.

## Promotions
- `promotions_list_root` – promotions page scaffold.

## RFQ
- `rfq_root` – RFQ creation page scaffold.
- `rfq_create_btn` – CTA to start a new RFQ draft.
- `rfq_line_add_btn` – Add line control within the RFQ form.
- `rfq_submit_btn` – Submit RFQ action button.
- `rfq_result_snackbar` – Snackbar used for RFQ success and error messaging.
- `rfq_view_quotes_btn` – CTA to open the latest quote detail page.
- `rfq_quote_card_{id}` – Quote version cards within the quote detail view.
- `rfq_convert_to_order_btn` – Convert quote to order button.

## Billing / Open Debts
- `open_debts_root` – billing page scaffold.
- `open_debts_export_btn` – summary card statement export action.
- `open_debts_invoice_<invoiceId>` – invoice cards (example: `open_debts_invoice_inv_a`).

## Saved Lists Cards
- `saved_list_add_all_btn_<listId>` – unique key on each Add All button (use in conjunction with `saved_list_add_all_btn`).

Guidance: prefer `find.byKey` against the keys above. For localized UI copy use `MarketplaceLocalizations` templates instead of hard-coded strings.
