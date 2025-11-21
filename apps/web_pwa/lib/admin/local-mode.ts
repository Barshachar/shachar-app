import { localModeError } from '@/lib/local-mode';

const ADMIN_LOCAL_MODE_MESSAGE = 'This admin endpoint requires APP_DATA_MODE=local';

export function assertLocalMode() {
  if (process.env.APP_DATA_MODE !== 'local') {
    throw localModeError(ADMIN_LOCAL_MODE_MESSAGE);
  }
}
