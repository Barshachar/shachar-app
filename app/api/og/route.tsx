import { ImageResponse } from 'next/og';

export const runtime = 'edge';
const width = 1200;
const height = 630;

function getParam(url: URL, key: string, fallback: string) {
  const value = url.searchParams.get(key);
  if (value && value.trim()) {
    return value.trim().slice(0, 120);
  }
  return fallback;
}

export async function GET(request: Request) {
  const url = new URL(request.url);
  const title = getParam(url, 'title', 'א.שחר • אינסטלציה סיטונאית');
  const subtitle = getParam(url, 'subtitle', 'קטלוג B2B/B2C מקומי');
  const badge = getParam(url, 'badge', 'מצב מקומי');

  return new ImageResponse(
    (
      <div
        style={{
          width: '1200px',
          height: '630px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          background: 'linear-gradient(135deg, #047857, #0ea5e9)',
          color: '#ffffff',
          padding: '80px'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              fontSize: '48px',
              fontWeight: 700,
              backgroundColor: '#ecfdf5',
              color: '#065f46',
              padding: '16px 32px',
              borderRadius: '999px'
            }}
          >
            {badge}
          </div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div style={{ fontSize: '64px', fontWeight: 700 }}>{title}</div>
          <div style={{ fontSize: '36px', opacity: 0.85 }}>{subtitle}</div>
        </div>
        <div style={{ fontSize: '28px', opacity: 0.65 }}>ashachar.co.il</div>
      </div>
    ),
    {
      width,
      height,
      headers: {
        'Cache-Control': 'public, max-age=86400'
      }
    }
  );
}
