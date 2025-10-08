import { ImageResponse } from 'next/og';
import {
  OG_IMAGE_HEIGHT,
  OG_IMAGE_WIDTH,
  extractOgParams,
  renderOgTemplate
} from '../../../../packages/ts/web_ui/src/og/template';

export const runtime = 'edge';

const DEFAULTS = {
  title: 'א.שחר • אינסטלציה סיטונאית',
  subtitle: 'קטלוג B2B/B2C מקומי',
  badge: 'מצב מקומי'
};

export async function GET(request: Request) {
  const url = new URL(request.url);
  const params = extractOgParams(url, DEFAULTS);

  return new ImageResponse(renderOgTemplate(params), {
    width: OG_IMAGE_WIDTH,
    height: OG_IMAGE_HEIGHT,
    headers: {
      'Cache-Control': 'public, max-age=86400'
    }
  });
}
