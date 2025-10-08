import Image from 'next/image';

export default function VendorBadge({
  vendor,
  size = 'medium'
}: {
  vendor: { name: string; logo_url?: string | null };
  size?: 'small' | 'medium';
}) {
  const dimension = size === 'small' ? 28 : 40;

  return (
    <div className="flex items-center gap-2 rounded-full border border-slate-200 bg-white px-2 py-1 text-xs text-slate-600 shadow-sm">
      <div className="relative flex items-center justify-center" style={{ width: dimension, height: dimension }}>
        <Image
          src={vendor.logo_url || '/placeholders/p0.png'}
          alt={vendor.name}
          width={dimension}
          height={dimension}
          className="rounded-full object-cover"
        />
      </div>
      <span className="font-semibold text-slate-700">{vendor.name}</span>
    </div>
  );
}
