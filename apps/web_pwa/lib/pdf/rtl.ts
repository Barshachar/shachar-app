const RTL_EMBED_START = '\u202B';
const RTL_EMBED_END = '\u202C';

const DIRECTIONAL_MARKS_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g;

export function stripDirectionalMarkers(text: string): string {
  return text.replace(DIRECTIONAL_MARKS_REGEX, '');
}

export function sanitizeNumberText(text: string): string {
  return stripDirectionalMarkers(text);
}

export function wrapRtl(text: string): string {
  return `${RTL_EMBED_START}${text}${RTL_EMBED_END}`;
}

