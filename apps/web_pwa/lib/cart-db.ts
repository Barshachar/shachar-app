import {
  ensureLocalCart,
  addLocalCartItem,
  updateLocalCartItem,
  removeLocalCartItem,
  clearLocalCart
} from '@/lib/local-store';

export async function ensureCart(sessionId: string): Promise<string> {
  return ensureLocalCart(sessionId);
}

export async function addCartItem({
  cartId,
  variantId,
  qty
}: {
  cartId: string;
  variantId: string;
  qty: number;
}) {
  await addLocalCartItem({ cartId, variantId, qty });
}

export async function updateCartItem({
  cartId,
  itemId,
  qty
}: {
  cartId: string;
  itemId: string;
  qty: number;
}) {
  if (qty <= 0) {
    await removeCartItem({ cartId, itemId });
    return;
  }
  await updateLocalCartItem({ cartId, itemId, qty });
}

export async function removeCartItem({ cartId, itemId }: { cartId: string; itemId: string }) {
  await removeLocalCartItem({ cartId, itemId });
}

export async function clearCart({ cartId }: { cartId: string }) {
  await clearLocalCart({ cartId });
}
