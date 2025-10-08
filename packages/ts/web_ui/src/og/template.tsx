// @ts-nocheck

export const OG_IMAGE_WIDTH = 1200;
export const OG_IMAGE_HEIGHT = 630;

export interface OgImageParams {
  title: string;
  subtitle: string;
  badge: string;
}

export interface OgDefaults {
  title: string;
  subtitle: string;
  badge: string;
}

export function sanitizeParam(
  value: string | null,
  fallback: string,
  limit = 120
): string {
  if (!value) {
    return fallback;
  }
  const trimmed = value.trim();
  if (!trimmed) {
    return fallback;
  }
  return trimmed.slice(0, limit);
}

export function extractOgParams(url: URL, defaults: OgDefaults): OgImageParams {
  return {
    title: sanitizeParam(url.searchParams.get('title'), defaults.title),
    subtitle: sanitizeParam(
      url.searchParams.get('subtitle'),
      defaults.subtitle
    ),
    badge: sanitizeParam(url.searchParams.get('badge'), defaults.badge, 40)
  };
}

export function renderOgTemplate({
  title,
  subtitle,
  badge
}: OgImageParams) {
  return (
    <div
      style={{
        width: `${OG_IMAGE_WIDTH}px`,
        height: `${OG_IMAGE_HEIGHT}px`,
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
  );
}
