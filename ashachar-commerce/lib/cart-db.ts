import { createServiceRoleClient } from '@/lib/supabase-server';
import {
  shouldUseLocalData,
  ensureLocalCart,
  addLocalCartItem,
  updateLocalCartItem,
  removeLocalCartItem,
  clearLocalCart
} from '@/lib/local-store';

type CartRow = { id: string };
type CartItemRow = { id: string; qty: number };

function isLocalMode() {
  return shouldUseLocalData();
}

export async function ensureCart(sessionId: string): Promise<string> {
  if (isLocalMode()) {
    return ensureLocalCart(sessionId);
  }

  const supabase = createServiceRoleClient();
  const { data, error } = await supabase
    .from('carts')
    .select('id')
    .eq('session_id', sessionId)
    .maybeSingle<CartRow>();

  if (error && error.code !== 'PGRST116') {
    throw error;
  }

  if (data?.id) {
    return data.id;
  }

  const payload = [{ session_id: sessionId }];
  const { data: inserted, error: insertError } = await supabase
    .from('carts')
    .insert(payload as never)
    .select('id')
    .single<CartRow>();

  if (insertError) {
    throw insertError;
  }

  return inserted.id;
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
  if (isLocalMode()) {
    await addLocalCartItem({ cartId, variantId, qty });
    return;
  }

  const supabase = createServiceRoleClient();
  const { error } = await (supabase as any).rpc('add_to_cart', {
    p_cart_id: cartId,
    p_variant_id: variantId,
    p_qty: qty
  });
  if (error) {
    const { data } = await supabase
      .from('cart_items')
      .select('id,qty')
      .eq('cart_id', cartId)
      .eq('variant_id', variantId)
      .maybeSingle<CartItemRow>();

    if (data) {
      const { error: updateError } = await supabase
        .from('cart_items')
        .update({ qty: data.qty + qty } as never)
        .eq('id', data.id)
        .eq('cart_id', cartId);
      if (updateError) {
        throw updateError;
      }
      return;
    }

    const insertPayload = [{ cart_id: cartId, variant_id: variantId, qty }];
    const { error: insertError } = await supabase
      .from('cart_items')
      .insert(insertPayload as never);
    if (insertError) {
      throw insertError;
    }
  }
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
  if (isLocalMode()) {
    await updateLocalCartItem({ cartId, itemId, qty });
    return;
  }

  const supabase = createServiceRoleClient();
  if (qty <= 0) {
    await removeCartItem({ cartId, itemId });
    return;
  }
  const { error } = await supabase
    .from('cart_items')
    .update({ qty } as never)
    .eq('id', itemId)
    .eq('cart_id', cartId);
  if (error) {
    throw error;
  }
}

export async function removeCartItem({ cartId, itemId }: { cartId: string; itemId: string }) {
  if (isLocalMode()) {
    await removeLocalCartItem({ cartId, itemId });
    return;
  }

  const supabase = createServiceRoleClient();
  const { error } = await supabase.from('cart_items').delete().eq('id', itemId).eq('cart_id', cartId);
  if (error) {
    throw error;
  }
}

export async function clearCart({ cartId }: { cartId: string }) {
  if (isLocalMode()) {
    await clearLocalCart({ cartId });
    return;
  }

  const supabase = createServiceRoleClient();
  const { error } = await supabase.from('cart_items').delete().eq('cart_id', cartId);
  if (error) {
    throw error;
  }
}
