set search_path = public, auth;

-- Add new order status used when approvals complete
DO $$
BEGIN
  ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'approved';
END;
$$;

-- Approval lifecycle enums
DO $$
BEGIN
  CREATE TYPE approval_request_status AS ENUM ('pending','approved','rejected','cancelled');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

DO $$
BEGIN
  CREATE TYPE approval_step_status AS ENUM ('pending','approved','rejected','skipped');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

-- Optional metadata for cost center scoping
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS cost_center_code text;

-- Master data: approval rules per company/category/cost center
CREATE TABLE IF NOT EXISTS approval_rules (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  priority int NOT NULL DEFAULT 100,
  min_amount numeric(14,2) NOT NULL DEFAULT 0,
  max_amount numeric(14,2),
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  cost_center_code text,
  approver_chain jsonb NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_by uuid NOT NULL REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT approval_rules_chain_is_array CHECK (jsonb_typeof(approver_chain) = 'array')
);

CREATE INDEX IF NOT EXISTS approval_rules_company_idx ON approval_rules(company_id, active, priority);

-- Runtime approval requests per order
CREATE TABLE IF NOT EXISTS approval_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  rule_id uuid REFERENCES approval_rules(id) ON DELETE SET NULL,
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  requester_user_id uuid NOT NULL REFERENCES auth.users(id),
  status approval_request_status NOT NULL DEFAULT 'pending',
  next_step_id uuid,
  decided_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(order_id)
);

CREATE INDEX IF NOT EXISTS approval_requests_company_idx ON approval_requests(company_id, status);
CREATE INDEX IF NOT EXISTS approval_requests_order_idx ON approval_requests(order_id);

-- Individual approval steps tied to requests
CREATE TABLE IF NOT EXISTS approval_steps (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id uuid NOT NULL REFERENCES approval_requests(id) ON DELETE CASCADE,
  step_order int NOT NULL,
  approver_user_id uuid NOT NULL REFERENCES auth.users(id),
  status approval_step_status NOT NULL DEFAULT 'pending',
  note text,
  responded_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(request_id, step_order)
);

CREATE INDEX IF NOT EXISTS approval_steps_request_idx ON approval_steps(request_id, status, step_order);
CREATE INDEX IF NOT EXISTS approval_steps_approver_idx ON approval_steps(approver_user_id, status);

DO $$
BEGIN
  ALTER TABLE approval_requests
    ADD CONSTRAINT approval_requests_next_step_fk
    FOREIGN KEY (next_step_id)
    REFERENCES approval_steps(id)
    ON DELETE SET NULL;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

-- Row Level Security configuration
ALTER TABLE approval_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_steps ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS approval_rules_admin_all ON approval_rules;
CREATE POLICY approval_rules_admin_all ON approval_rules
  FOR ALL
  USING (auth_role() = 'admin')
  WITH CHECK (auth_role() = 'admin');

DROP POLICY IF EXISTS approval_rules_company_select ON approval_rules;
CREATE POLICY approval_rules_company_select ON approval_rules
  FOR SELECT TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_rules_company_manage ON approval_rules;
CREATE POLICY approval_rules_company_manage ON approval_rules
  FOR INSERT TO authenticated
  WITH CHECK (
    auth_role() = 'customer_admin'
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_rules_company_update ON approval_rules;
CREATE POLICY approval_rules_company_update ON approval_rules
  FOR UPDATE TO authenticated
  USING (
    auth_role() = 'customer_admin'
    AND company_id = auth_company_id()
  )
  WITH CHECK (
    auth_role() = 'customer_admin'
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_rules_company_delete ON approval_rules;
CREATE POLICY approval_rules_company_delete ON approval_rules
  FOR DELETE TO authenticated
  USING (
    auth_role() = 'customer_admin'
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_requests_admin_all ON approval_requests;
CREATE POLICY approval_requests_admin_all ON approval_requests
  FOR ALL
  USING (auth_role() = 'admin')
  WITH CHECK (auth_role() = 'admin');

DROP POLICY IF EXISTS approval_requests_company_select ON approval_requests;
CREATE POLICY approval_requests_company_select ON approval_requests
  FOR SELECT TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_requests_company_insert ON approval_requests;
CREATE POLICY approval_requests_company_insert ON approval_requests
  FOR INSERT TO authenticated
  WITH CHECK (
    auth_role() IN ('customer_admin','buyer')
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_requests_company_update ON approval_requests;
CREATE POLICY approval_requests_company_update ON approval_requests
  FOR UPDATE TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND company_id = auth_company_id()
  )
  WITH CHECK (
    auth_role() IN ('customer_admin','buyer')
    AND company_id = auth_company_id()
  );

DROP POLICY IF EXISTS approval_steps_admin_all ON approval_steps;
CREATE POLICY approval_steps_admin_all ON approval_steps
  FOR ALL
  USING (auth_role() = 'admin')
  WITH CHECK (auth_role() = 'admin');

DROP POLICY IF EXISTS approval_steps_company_select ON approval_steps;
CREATE POLICY approval_steps_company_select ON approval_steps
  FOR SELECT TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND EXISTS (
      SELECT 1
        FROM approval_requests ar
       WHERE ar.id = approval_steps.request_id
         AND ar.company_id = auth_company_id()
    )
  );

DROP POLICY IF EXISTS approval_steps_company_insert ON approval_steps;
CREATE POLICY approval_steps_company_insert ON approval_steps
  FOR INSERT TO authenticated
  WITH CHECK (
    auth_role() IN ('customer_admin','buyer')
    AND EXISTS (
      SELECT 1
        FROM approval_requests ar
       WHERE ar.id = approval_steps.request_id
         AND ar.company_id = auth_company_id()
    )
  );

DROP POLICY IF EXISTS approval_steps_self_update ON approval_steps;
CREATE POLICY approval_steps_self_update ON approval_steps
  FOR UPDATE TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND approver_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM approval_requests ar
       WHERE ar.id = approval_steps.request_id
         AND ar.company_id = auth_company_id()
    )
  )
  WITH CHECK (
    auth_role() IN ('customer_admin','buyer')
    AND approver_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM approval_requests ar
       WHERE ar.id = approval_steps.request_id
         AND ar.company_id = auth_company_id()
    )
  );

DROP POLICY IF EXISTS approval_steps_company_delete ON approval_steps;
CREATE POLICY approval_steps_company_delete ON approval_steps
  FOR DELETE TO authenticated
  USING (
    auth_role() = 'customer_admin'
    AND EXISTS (
      SELECT 1
        FROM approval_requests ar
       WHERE ar.id = approval_steps.request_id
         AND ar.company_id = auth_company_id()
    )
  );

-- RPCs for approval lifecycle
DROP FUNCTION IF EXISTS rpc_evaluate_approvals(uuid);
CREATE OR REPLACE FUNCTION rpc_evaluate_approvals(p_order_id uuid)
RETURNS jsonb AS $$
DECLARE
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_order orders%rowtype;
  v_request approval_requests%rowtype;
  v_rule approval_rules%rowtype;
  v_next_step_id uuid;
  v_step_payload jsonb;
  v_step_index int := 0;
  v_approver uuid;
  v_total numeric(14,2);
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING errcode = '28000';
  END IF;

  SELECT *
    INTO v_order
    FROM orders
   WHERE id = p_order_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order % not found', p_order_id;
  END IF;

  IF v_role NOT IN ('admin','customer_admin','buyer') THEN
    RAISE EXCEPTION 'Role % not permitted for approvals', v_role;
  END IF;

  IF v_role <> 'admin' AND v_order.customer_company_id <> v_company THEN
    RAISE EXCEPTION 'Tenant violation for order %', p_order_id USING errcode = '42501';
  END IF;

  SELECT *
    INTO v_request
    FROM approval_requests
   WHERE order_id = p_order_id;

  IF v_request.id IS NULL THEN
    v_total := COALESCE(v_order.total, 0);
    IF v_total <= 0 THEN
      SELECT COALESCE(SUM(line_total), 0)
        INTO v_total
        FROM order_items
       WHERE order_id = p_order_id;
    END IF;

    SELECT r.*
      INTO v_rule
      FROM approval_rules r
     WHERE r.company_id = v_order.customer_company_id
       AND r.active = true
       AND COALESCE(r.min_amount, 0) <= v_total
       AND (r.max_amount IS NULL OR v_total <= r.max_amount)
       AND (
         r.category_id IS NULL
         OR EXISTS (
             SELECT 1
               FROM order_items oi
               JOIN product_variants pv ON pv.id = oi.variant_id
               JOIN products pr ON pr.id = pv.product_id
              WHERE oi.order_id = p_order_id
                AND pr.category_id = r.category_id
         )
       )
       AND (
         r.cost_center_code IS NULL
         OR r.cost_center_code IS NOT DISTINCT FROM v_order.cost_center_code
       )
     ORDER BY r.priority ASC, COALESCE(r.min_amount, 0) DESC
     LIMIT 1;

    IF v_rule.id IS NULL OR jsonb_array_length(v_rule.approver_chain) = 0 THEN
      UPDATE orders
         SET status = 'approved',
             updated_at = now()
       WHERE id = p_order_id
         AND status <> 'approved';

      INSERT INTO audit_log(actor_user_id, action, table_name, row_id, metadata)
      VALUES (
        v_user,
        'approval_auto_granted',
        'orders',
        p_order_id,
        jsonb_build_object('reason', 'no_matching_rule')
      );

      RETURN jsonb_build_object(
        'order_id', p_order_id,
        'status', 'approved',
        'auto_approved', true,
        'request_id', NULL,
        'steps', jsonb_build_array(),
        'next_step', NULL
      );
    END IF;

    INSERT INTO approval_requests(order_id, rule_id, company_id, requester_user_id, status, created_at, updated_at)
    VALUES (p_order_id, v_rule.id, v_order.customer_company_id, v_user, 'pending', now(), now())
    RETURNING * INTO v_request;

    FOR v_step_payload IN SELECT * FROM jsonb_array_elements(v_rule.approver_chain)
    LOOP
      v_step_index := v_step_index + 1;
      v_approver := NULL;

      BEGIN
        v_approver := (v_step_payload->>'approver_user_id')::uuid;
      EXCEPTION WHEN others THEN
        v_approver := NULL;
      END;

      IF v_approver IS NULL THEN
        BEGIN
          v_approver := (v_step_payload->>'user_id')::uuid;
        EXCEPTION WHEN others THEN
          v_approver := NULL;
        END;
      END IF;

      IF v_approver IS NULL AND v_step_payload ? 'role' THEN
        BEGIN
          SELECT cu.user_id
            INTO v_approver
            FROM company_users cu
           WHERE cu.company_id = v_rule.company_id
             AND cu.role = (v_step_payload->>'role')::user_role
           ORDER BY cu.role, cu.user_id
           LIMIT 1;
        EXCEPTION WHEN others THEN
          v_approver := NULL;
        END;
      END IF;

      IF v_approver IS NULL THEN
        RAISE EXCEPTION 'Approval rule % missing approver for step %', v_rule.id, v_step_index;
      END IF;

      IF NOT EXISTS (
        SELECT 1
          FROM company_users cu
         WHERE cu.company_id = v_rule.company_id
           AND cu.user_id = v_approver
      ) THEN
        RAISE EXCEPTION 'Approver % not part of company %', v_approver, v_rule.company_id;
      END IF;

      INSERT INTO approval_steps(request_id, step_order, approver_user_id, status, created_at, updated_at)
      VALUES (v_request.id, v_step_index, v_approver, 'pending', now(), now());
    END LOOP;

    SELECT id
      INTO v_next_step_id
      FROM approval_steps
     WHERE request_id = v_request.id
       AND status = 'pending'
     ORDER BY step_order
     LIMIT 1;

    UPDATE approval_requests
       SET next_step_id = v_next_step_id,
           updated_at = now()
     WHERE id = v_request.id
     RETURNING * INTO v_request;

    INSERT INTO audit_log(actor_user_id, action, table_name, row_id, metadata)
    VALUES (
      v_user,
      'approval_request_created',
      'approval_requests',
      v_request.id,
      jsonb_build_object('order_id', p_order_id, 'rule_id', v_rule.id, 'steps', jsonb_array_length(v_rule.approver_chain))
    );
  ELSE
    SELECT id
      INTO v_next_step_id
      FROM approval_steps
     WHERE request_id = v_request.id
       AND status = 'pending'
     ORDER BY step_order
     LIMIT 1;

    IF v_request.next_step_id IS DISTINCT FROM v_next_step_id THEN
      UPDATE approval_requests
         SET next_step_id = v_next_step_id,
             updated_at = now()
       WHERE id = v_request.id
       RETURNING * INTO v_request;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'order_id', p_order_id,
    'request_id', v_request.id,
    'status', v_request.status,
    'rule_id', v_request.rule_id,
    'next_step', (
      SELECT jsonb_build_object(
               'step_id', s.id,
               'approver_user_id', s.approver_user_id,
               'step_order', s.step_order,
               'status', s.status
             )
        FROM approval_steps s
       WHERE s.id = v_request.next_step_id
    ),
    'steps', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
               'step_id', s.id,
               'approver_user_id', s.approver_user_id,
               'step_order', s.step_order,
               'status', s.status,
               'note', s.note,
               'responded_at', s.responded_at
             ) ORDER BY s.step_order)
        FROM approval_steps s
       WHERE s.request_id = v_request.id
    ), '[]'::jsonb)
  );
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION rpc_evaluate_approvals(uuid) TO authenticated;

DROP FUNCTION IF EXISTS rpc_approve_step(uuid, boolean, text);
CREATE OR REPLACE FUNCTION rpc_approve_step(p_step_id uuid, p_approve boolean, p_note text)
RETURNS jsonb AS $$
DECLARE
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_step approval_steps%rowtype;
  v_request approval_requests%rowtype;
  v_order orders%rowtype;
  v_next_step_id uuid;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING errcode = '28000';
  END IF;

  SELECT s.*, r.*, o.*
    INTO v_step, v_request, v_order
    FROM approval_steps s
    JOIN approval_requests r ON r.id = s.request_id
    JOIN orders o ON o.id = r.order_id
   WHERE s.id = p_step_id
   FOR UPDATE OF s, r, o;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Approval step % not found', p_step_id;
  END IF;

  IF v_role <> 'admin' THEN
    IF v_order.customer_company_id <> v_company THEN
      RAISE EXCEPTION 'Tenant violation for step %', p_step_id USING errcode = '42501';
    END IF;

    IF v_step.approver_user_id <> v_user THEN
      RAISE EXCEPTION 'Step % assigned to a different approver', p_step_id USING errcode = '42501';
    END IF;
  END IF;

  IF v_request.status <> 'pending' THEN
    RAISE EXCEPTION 'Approval request already resolved';
  END IF;

  IF v_step.status <> 'pending' THEN
    RAISE EXCEPTION 'Approval step already decided';
  END IF;

  UPDATE approval_steps
     SET status = CASE WHEN p_approve THEN 'approved' ELSE 'rejected' END,
         note = COALESCE(p_note, note),
         responded_at = now(),
         updated_at = now()
   WHERE id = p_step_id
   RETURNING * INTO v_step;

  IF NOT p_approve THEN
    UPDATE approval_requests
       SET status = 'rejected',
           decided_at = now(),
           next_step_id = NULL,
           updated_at = now()
     WHERE id = v_request.id
     RETURNING * INTO v_request;

    UPDATE orders
       SET status = 'cancelled',
           updated_at = now()
     WHERE id = v_order.id
     RETURNING * INTO v_order;

    INSERT INTO audit_log(actor_user_id, action, table_name, row_id, metadata)
    VALUES (
      v_user,
      'approval_step_rejected',
      'approval_steps',
      v_step.id,
      jsonb_build_object('order_id', v_order.id, 'request_id', v_request.id, 'step_order', v_step.step_order)
    );

    RETURN jsonb_build_object(
      'order_id', v_order.id,
      'order_status', v_order.status,
      'request_id', v_request.id,
      'request_status', v_request.status,
      'step_id', v_step.id,
      'step_status', v_step.status,
      'next_step', NULL,
      'steps', COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
                 'step_id', s.id,
                 'approver_user_id', s.approver_user_id,
                 'step_order', s.step_order,
                 'status', s.status,
                 'note', s.note,
                 'responded_at', s.responded_at
               ) ORDER BY s.step_order)
          FROM approval_steps s
         WHERE s.request_id = v_request.id
      ), '[]'::jsonb)
    );
  END IF;

  SELECT id
    INTO v_next_step_id
    FROM approval_steps
   WHERE request_id = v_request.id
     AND status = 'pending'
   ORDER BY step_order
   LIMIT 1;

  IF v_next_step_id IS NULL THEN
    UPDATE approval_requests
       SET status = 'approved',
           decided_at = now(),
           next_step_id = NULL,
           updated_at = now()
     WHERE id = v_request.id
     RETURNING * INTO v_request;

    UPDATE orders
       SET status = 'approved',
           updated_at = now()
     WHERE id = v_order.id
     RETURNING * INTO v_order;

    INSERT INTO audit_log(actor_user_id, action, table_name, row_id, metadata)
    VALUES (
      v_user,
      'approval_request_completed',
      'approval_requests',
      v_request.id,
      jsonb_build_object('order_id', v_order.id, 'step_id', v_step.id)
    );
  ELSE
    UPDATE approval_requests
       SET next_step_id = v_next_step_id,
           updated_at = now()
     WHERE id = v_request.id
     RETURNING * INTO v_request;

    INSERT INTO audit_log(actor_user_id, action, table_name, row_id, metadata)
    VALUES (
      v_user,
      'approval_step_approved',
      'approval_steps',
      v_step.id,
      jsonb_build_object('order_id', v_order.id, 'request_id', v_request.id, 'next_step_id', v_next_step_id)
    );
  END IF;

  RETURN jsonb_build_object(
    'order_id', v_order.id,
    'order_status', v_order.status,
    'request_id', v_request.id,
    'request_status', v_request.status,
    'step_id', v_step.id,
    'step_status', v_step.status,
    'next_step', (
      SELECT jsonb_build_object(
               'step_id', s.id,
               'approver_user_id', s.approver_user_id,
               'step_order', s.step_order,
               'status', s.status
             )
        FROM approval_steps s
       WHERE s.id = v_request.next_step_id
    ),
    'steps', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
               'step_id', s.id,
               'approver_user_id', s.approver_user_id,
               'step_order', s.step_order,
               'status', s.status,
               'note', s.note,
               'responded_at', s.responded_at
             ) ORDER BY s.step_order)
        FROM approval_steps s
       WHERE s.request_id = v_request.id
    ), '[]'::jsonb)
  );
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION rpc_approve_step(uuid, boolean, text) TO authenticated;
