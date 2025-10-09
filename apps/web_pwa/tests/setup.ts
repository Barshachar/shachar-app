process.env.CARD_COM_PAGE_URL = 'https://secure.cardcom.solutions/e/demo/';
process.env.CARD_COM_SUCCESS_URL = 'https://example.com/success';
process.env.CARD_COM_ERROR_URL = 'https://example.com/fail';
process.env.APP_DATA_MODE = 'local';
if (!process.env.PDF_FONT_PATH) {
  process.env.PDF_FONT_PATH = `${process.cwd()}/public/fonts/NotoSansHebrew.ttf`;
}
