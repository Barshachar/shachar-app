export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      approval_requests: {
        Row: {
          approver_user_id: string
          company_id: string
          created_at: string
          entity_id: string
          entity_type: string
          id: string
          notes: string | null
          request_type: string
          requester_user_id: string
          reviewed_at: string | null
          status: string
          updated_at: string
        }
        Insert: {
          approver_user_id: string
          company_id: string
          created_at?: string
          entity_id: string
          entity_type: string
          id?: string
          notes?: string | null
          request_type: string
          requester_user_id: string
          reviewed_at?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          approver_user_id?: string
          company_id?: string
          created_at?: string
          entity_id?: string
          entity_type?: string
          id?: string
          notes?: string | null
          request_type?: string
          requester_user_id?: string
          reviewed_at?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "approval_requests_approver_user_id_fkey"
            columns: ["approver_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approval_requests_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approval_requests_requester_user_id_fkey"
            columns: ["requester_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      attachments: {
        Row: {
          created_at: string
          created_by: string
          file_url: string
          id: string
          owner_id: string
          owner_table: string
          type: string
        }
        Insert: {
          created_at?: string
          created_by: string
          file_url: string
          id?: string
          owner_id: string
          owner_table: string
          type: string
        }
        Update: {
          created_at?: string
          created_by?: string
          file_url?: string
          id?: string
          owner_id?: string
          owner_table?: string
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "attachments_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      attributes: {
        Row: {
          code: string
          created_at: string
          id: string
          name: Json
          type: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          name: Json
          type: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          name?: Json
          type?: string
        }
        Relationships: []
      }
      audit_log: {
        Row: {
          action: string
          actor_user_id: string
          created_at: string
          id: string
          metadata: Json | null
          row_id: string | null
          table_name: string
        }
        Insert: {
          action: string
          actor_user_id: string
          created_at?: string
          id?: string
          metadata?: Json | null
          row_id?: string | null
          table_name: string
        }
        Update: {
          action?: string
          actor_user_id?: string
          created_at?: string
          id?: string
          metadata?: Json | null
          row_id?: string | null
          table_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "audit_log_actor_user_id_fkey"
            columns: ["actor_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      categories: {
        Row: {
          created_at: string
          id: string
          name: Json
          parent_id: string | null
          sort_order: number
        }
        Insert: {
          created_at?: string
          id?: string
          name: Json
          parent_id?: string | null
          sort_order?: number
        }
        Update: {
          created_at?: string
          id?: string
          name?: Json
          parent_id?: string | null
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      companies: {
        Row: {
          created_at: string
          currency: string
          id: string
          locale: string
          name: string
          status: Database["public"]["Enums"]["company_status"]
          timezone: string
          type: Database["public"]["Enums"]["company_type"]
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          id?: string
          locale?: string
          name: string
          status?: Database["public"]["Enums"]["company_status"]
          timezone?: string
          type: Database["public"]["Enums"]["company_type"]
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          id?: string
          locale?: string
          name?: string
          status?: Database["public"]["Enums"]["company_status"]
          timezone?: string
          type?: Database["public"]["Enums"]["company_type"]
          updated_at?: string
        }
        Relationships: []
      }
      company_users: {
        Row: {
          active: boolean
          company_id: string
          created_at: string
          role: Database["public"]["Enums"]["user_role"]
          user_id: string
        }
        Insert: {
          active?: boolean
          company_id: string
          created_at?: string
          role: Database["public"]["Enums"]["user_role"]
          user_id: string
        }
        Update: {
          active?: boolean
          company_id?: string
          created_at?: string
          role?: Database["public"]["Enums"]["user_role"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "company_users_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "company_users_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      cost_centers: {
        Row: {
          approver_name: string | null
          approver_user_id: string | null
          auto_assign_rules: Json
          business_unit: string
          code: string
          company_id: string
          created_at: string
          department: string
          id: string
          name: string
          notes: string | null
          requires_approver: boolean
          status: Database["public"]["Enums"]["cost_center_status"]
          updated_at: string
          ytd_budget: number
          ytd_spent: number
        }
        Insert: {
          approver_name?: string | null
          approver_user_id?: string | null
          auto_assign_rules?: Json
          business_unit: string
          code: string
          company_id: string
          created_at?: string
          department: string
          id?: string
          name: string
          notes?: string | null
          requires_approver?: boolean
          status?: Database["public"]["Enums"]["cost_center_status"]
          updated_at?: string
          ytd_budget?: number
          ytd_spent?: number
        }
        Update: {
          approver_name?: string | null
          approver_user_id?: string | null
          auto_assign_rules?: Json
          business_unit?: string
          code?: string
          company_id?: string
          created_at?: string
          department?: string
          id?: string
          name?: string
          notes?: string | null
          requires_approver?: boolean
          status?: Database["public"]["Enums"]["cost_center_status"]
          updated_at?: string
          ytd_budget?: number
          ytd_spent?: number
        }
        Relationships: [
          {
            foreignKeyName: "cost_centers_approver_user_id_fkey"
            columns: ["approver_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_centers_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_profiles: {
        Row: {
          account_tier: string
          city: string | null
          country: string | null
          created_at: string
          customer_id: string
          industry: string | null
          phone: string | null
          postal_code: string | null
          sales_rep_email: string | null
          sales_rep_name: string | null
          street_address: string | null
          updated_at: string
        }
        Insert: {
          account_tier: string
          city?: string | null
          country?: string | null
          created_at?: string
          customer_id: string
          industry?: string | null
          phone?: string | null
          postal_code?: string | null
          sales_rep_email?: string | null
          sales_rep_name?: string | null
          street_address?: string | null
          updated_at?: string
        }
        Update: {
          account_tier?: string
          city?: string | null
          country?: string | null
          created_at?: string
          customer_id?: string
          industry?: string | null
          phone?: string | null
          postal_code?: string | null
          sales_rep_email?: string | null
          sales_rep_name?: string | null
          street_address?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "customer_profiles_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      inventory: {
        Row: {
          low_stock_threshold: number
          qty: number
          updated_at: string
          variant_id: string
        }
        Insert: {
          low_stock_threshold?: number
          qty?: number
          updated_at?: string
          variant_id: string
        }
        Update: {
          low_stock_threshold?: number
          qty?: number
          updated_at?: string
          variant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "inventory_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: true
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          body: string
          created_at: string
          data: Json | null
          id: string
          read_at: string | null
          title: string
          user_id: string
        }
        Insert: {
          body: string
          created_at?: string
          data?: Json | null
          id?: string
          read_at?: string | null
          title: string
          user_id: string
        }
        Update: {
          body?: string
          created_at?: string
          data?: Json | null
          id?: string
          read_at?: string | null
          title?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      order_items: {
        Row: {
          discount_pct: number
          id: string
          line_total: number | null
          order_id: string
          qty: number
          tax_rate: number
          unit_price: number
          uom: string
          variant_id: string
          vendor_company_id: string
        }
        Insert: {
          discount_pct?: number
          id?: string
          line_total?: number | null
          order_id: string
          qty: number
          tax_rate?: number
          unit_price: number
          uom?: string
          variant_id: string
          vendor_company_id: string
        }
        Update: {
          discount_pct?: number
          id?: string
          line_total?: number | null
          order_id?: string
          qty?: number
          tax_rate?: number
          unit_price?: number
          uom?: string
          variant_id?: string
          vendor_company_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "v_vendor_orders"
            referencedColumns: ["order_id"]
          },
          {
            foreignKeyName: "order_items_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_vendor_company_id_fkey"
            columns: ["vendor_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          created_at: string
          created_by: string
          currency: string
          customer_company_id: string
          delivery_window: unknown
          id: string
          notes: string | null
          order_number: string | null
          status: Database["public"]["Enums"]["order_status"]
          subtotal: number
          tax_total: number
          total: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          created_by: string
          currency?: string
          customer_company_id: string
          delivery_window?: unknown
          id?: string
          notes?: string | null
          order_number?: string | null
          status?: Database["public"]["Enums"]["order_status"]
          subtotal?: number
          tax_total?: number
          total?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          created_by?: string
          currency?: string
          customer_company_id?: string
          delivery_window?: unknown
          id?: string
          notes?: string | null
          order_number?: string | null
          status?: Database["public"]["Enums"]["order_status"]
          subtotal?: number
          tax_total?: number
          total?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_customer_company_id_fkey"
            columns: ["customer_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      payment_events: {
        Row: {
          created_at: string
          id: string
          order_id: string | null
          payload: Json | null
          provider: string
          transaction_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          order_id?: string | null
          payload?: Json | null
          provider: string
          transaction_id: string
        }
        Update: {
          created_at?: string
          id?: string
          order_id?: string | null
          payload?: Json | null
          provider?: string
          transaction_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "payment_events_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_events_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "v_vendor_orders"
            referencedColumns: ["order_id"]
          },
        ]
      }
      payment_terms_templates: {
        Row: {
          code: Database["public"]["Enums"]["payment_terms_code"]
          created_at: string
          description: string | null
          display_name: string
          id: string
          net_days: number
          updated_at: string
        }
        Insert: {
          code: Database["public"]["Enums"]["payment_terms_code"]
          created_at?: string
          description?: string | null
          display_name: string
          id?: string
          net_days: number
          updated_at?: string
        }
        Update: {
          code?: Database["public"]["Enums"]["payment_terms_code"]
          created_at?: string
          description?: string | null
          display_name?: string
          id?: string
          net_days?: number
          updated_at?: string
        }
        Relationships: []
      }
      price_lists: {
        Row: {
          created_at: string
          currency: string
          id: string
          name: string
          priority: number
          scope: Database["public"]["Enums"]["price_list_scope"]
          target_id: string | null
          updated_at: string
          valid_from: string
          valid_to: string | null
          vendor_company_id: string
        }
        Insert: {
          created_at?: string
          currency?: string
          id?: string
          name: string
          priority?: number
          scope: Database["public"]["Enums"]["price_list_scope"]
          target_id?: string | null
          updated_at?: string
          valid_from?: string
          valid_to?: string | null
          vendor_company_id: string
        }
        Update: {
          created_at?: string
          currency?: string
          id?: string
          name?: string
          priority?: number
          scope?: Database["public"]["Enums"]["price_list_scope"]
          target_id?: string | null
          updated_at?: string
          valid_from?: string
          valid_to?: string | null
          vendor_company_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "price_lists_vendor_company_id_fkey"
            columns: ["vendor_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      prices: {
        Row: {
          created_at: string
          id: string
          min_qty: number
          price_list_id: string
          unit_price: number
          variant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          min_qty?: number
          price_list_id: string
          unit_price: number
          variant_id: string
        }
        Update: {
          created_at?: string
          id?: string
          min_qty?: number
          price_list_id?: string
          unit_price?: number
          variant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "prices_price_list_id_fkey"
            columns: ["price_list_id"]
            isOneToOne: false
            referencedRelation: "price_lists"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prices_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      product_variants: {
        Row: {
          active: boolean
          attributes_json: Json
          barcode: string | null
          created_at: string
          id: string
          product_id: string
          sku: string
          uom: string
          updated_at: string
        }
        Insert: {
          active?: boolean
          attributes_json: Json
          barcode?: string | null
          created_at?: string
          id?: string
          product_id: string
          sku: string
          uom?: string
          updated_at?: string
        }
        Update: {
          active?: boolean
          attributes_json?: Json
          barcode?: string | null
          created_at?: string
          id?: string
          product_id?: string
          sku?: string
          uom?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_variants_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          active: boolean
          category_id: string | null
          created_at: string
          description: Json | null
          id: string
          lead_time: number
          moq: number
          name: Json
          pack_size: number
          sku: string
          uom: string
          updated_at: string
          vendor_company_id: string
        }
        Insert: {
          active?: boolean
          category_id?: string | null
          created_at?: string
          description?: Json | null
          id?: string
          lead_time?: number
          moq?: number
          name: Json
          pack_size?: number
          sku: string
          uom?: string
          updated_at?: string
          vendor_company_id: string
        }
        Update: {
          active?: boolean
          category_id?: string | null
          created_at?: string
          description?: Json | null
          id?: string
          lead_time?: number
          moq?: number
          name?: Json
          pack_size?: number
          sku?: string
          uom?: string
          updated_at?: string
          vendor_company_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "products_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "products_vendor_company_id_fkey"
            columns: ["vendor_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      promotion_products: {
        Row: {
          created_at: string
          discount_pct: number
          id: string
          product_id: string
          promotion_id: string
          special_price: number | null
        }
        Insert: {
          created_at?: string
          discount_pct?: number
          id?: string
          product_id: string
          promotion_id: string
          special_price?: number | null
        }
        Update: {
          created_at?: string
          discount_pct?: number
          id?: string
          product_id?: string
          promotion_id?: string
          special_price?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "promotion_products_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "promotion_products_promotion_id_fkey"
            columns: ["promotion_id"]
            isOneToOne: false
            referencedRelation: "promotions"
            referencedColumns: ["id"]
          },
        ]
      }
      promotions: {
        Row: {
          active: boolean
          badge_label: Json
          created_at: string
          description: Json | null
          id: string
          image_url: string | null
          priority: number
          tags: string[] | null
          target_customer_ids: string[] | null
          terms: Json | null
          title: Json
          updated_at: string
          valid_from: string
          valid_to: string
        }
        Insert: {
          active?: boolean
          badge_label: Json
          created_at?: string
          description?: Json | null
          id?: string
          image_url?: string | null
          priority?: number
          tags?: string[] | null
          target_customer_ids?: string[] | null
          terms?: Json | null
          title: Json
          updated_at?: string
          valid_from?: string
          valid_to: string
        }
        Update: {
          active?: boolean
          badge_label?: Json
          created_at?: string
          description?: Json | null
          id?: string
          image_url?: string | null
          priority?: number
          tags?: string[] | null
          target_customer_ids?: string[] | null
          terms?: Json | null
          title?: Json
          updated_at?: string
          valid_from?: string
          valid_to?: string
        }
        Relationships: []
      }
      returns: {
        Row: {
          created_at: string
          id: string
          item_id: string
          order_id: string
          qty: number
          reason: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          item_id: string
          order_id: string
          qty: number
          reason?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          item_id?: string
          order_id?: string
          qty?: number
          reason?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "returns_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "order_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "returns_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "returns_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "v_vendor_orders"
            referencedColumns: ["order_id"]
          },
        ]
      }
      saved_list_items: {
        Row: {
          created_at: string
          id: string
          list_id: string
          quantity: number
          uom: string
          variant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          list_id: string
          quantity?: number
          uom?: string
          variant_id: string
        }
        Update: {
          created_at?: string
          id?: string
          list_id?: string
          quantity?: number
          uom?: string
          variant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_list_items_list_id_fkey"
            columns: ["list_id"]
            isOneToOne: false
            referencedRelation: "saved_lists"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "saved_list_items_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_lists: {
        Row: {
          created_at: string
          customer_id: string
          id: string
          name: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          customer_id: string
          id?: string
          name: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          customer_id?: string
          id?: string
          name?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_lists_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      shipments: {
        Row: {
          created_at: string
          id: string
          order_id: string
          partial_flag: boolean
          status: Database["public"]["Enums"]["shipment_status"]
          tracking: string | null
          updated_at: string
          vendor_company_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          order_id: string
          partial_flag?: boolean
          status?: Database["public"]["Enums"]["shipment_status"]
          tracking?: string | null
          updated_at?: string
          vendor_company_id: string
        }
        Update: {
          created_at?: string
          id?: string
          order_id?: string
          partial_flag?: boolean
          status?: Database["public"]["Enums"]["shipment_status"]
          tracking?: string | null
          updated_at?: string
          vendor_company_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "shipments_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shipments_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "v_vendor_orders"
            referencedColumns: ["order_id"]
          },
          {
            foreignKeyName: "shipments_vendor_company_id_fkey"
            columns: ["vendor_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      support_tickets: {
        Row: {
          assigned_to: string | null
          company_id: string
          created_at: string
          description: string | null
          id: string
          priority: Database["public"]["Enums"]["support_ticket_priority"]
          requester_id: string | null
          sla_due: string | null
          status: Database["public"]["Enums"]["support_ticket_status"]
          subject: string
          updated_at: string
        }
        Insert: {
          assigned_to?: string | null
          company_id: string
          created_at?: string
          description?: string | null
          id?: string
          priority?: Database["public"]["Enums"]["support_ticket_priority"]
          requester_id?: string | null
          sla_due?: string | null
          status?: Database["public"]["Enums"]["support_ticket_status"]
          subject: string
          updated_at?: string
        }
        Update: {
          assigned_to?: string | null
          company_id?: string
          created_at?: string
          description?: string | null
          id?: string
          priority?: Database["public"]["Enums"]["support_ticket_priority"]
          requester_id?: string | null
          sla_due?: string | null
          status?: Database["public"]["Enums"]["support_ticket_status"]
          subject?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_tickets_assigned_to_fkey"
            columns: ["assigned_to"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_requester_id_fkey"
            columns: ["requester_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      vendor_metrics: {
        Row: {
          created_at: string
          lead_time_days: number
          minimum_order_qty: number
          on_time_percent: number
          preferred: boolean
          rating: number
          updated_at: string
          vendor_id: string
        }
        Insert: {
          created_at?: string
          lead_time_days?: number
          minimum_order_qty?: number
          on_time_percent?: number
          preferred?: boolean
          rating?: number
          updated_at?: string
          vendor_id: string
        }
        Update: {
          created_at?: string
          lead_time_days?: number
          minimum_order_qty?: number
          on_time_percent?: number
          preferred?: boolean
          rating?: number
          updated_at?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_metrics_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: true
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      vendor_payment_term_options: {
        Row: {
          id: string
          is_allowed: boolean
          terms_id: string
          vendor_id: string
        }
        Insert: {
          id?: string
          is_allowed?: boolean
          terms_id: string
          vendor_id: string
        }
        Update: {
          id?: string
          is_allowed?: boolean
          terms_id?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_payment_term_options_terms_id_fkey"
            columns: ["terms_id"]
            isOneToOne: false
            referencedRelation: "payment_terms_templates"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendor_payment_term_options_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      vendor_payment_term_overrides: {
        Row: {
          created_at: string
          customer_id: string
          id: string
          terms_id: string
          vendor_id: string
        }
        Insert: {
          created_at?: string
          customer_id: string
          id?: string
          terms_id: string
          vendor_id: string
        }
        Update: {
          created_at?: string
          customer_id?: string
          id?: string
          terms_id?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_payment_term_overrides_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendor_payment_term_overrides_terms_id_fkey"
            columns: ["terms_id"]
            isOneToOne: false
            referencedRelation: "payment_terms_templates"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendor_payment_term_overrides_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      vendor_payment_term_settings: {
        Row: {
          allow_vendor_overrides: boolean
          created_at: string
          default_terms_id: string
          early_pay_discount_days: number | null
          early_pay_discount_pct: number | null
          grace_period_days: number | null
          late_fee_interest_pct: number | null
          updated_at: string
          vendor_id: string
        }
        Insert: {
          allow_vendor_overrides?: boolean
          created_at?: string
          default_terms_id: string
          early_pay_discount_days?: number | null
          early_pay_discount_pct?: number | null
          grace_period_days?: number | null
          late_fee_interest_pct?: number | null
          updated_at?: string
          vendor_id: string
        }
        Update: {
          allow_vendor_overrides?: boolean
          created_at?: string
          default_terms_id?: string
          early_pay_discount_days?: number | null
          early_pay_discount_pct?: number | null
          grace_period_days?: number | null
          late_fee_interest_pct?: number | null
          updated_at?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_payment_term_settings_default_terms_id_fkey"
            columns: ["default_terms_id"]
            isOneToOne: false
            referencedRelation: "payment_terms_templates"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendor_payment_term_settings_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: true
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      warehouse_bins: {
        Row: {
          aisle: string
          bin: string
          capacity: number | null
          current_qty: number
          fill_state: Database["public"]["Enums"]["warehouse_bin_fill"]
          id: string
          updated_at: string
          zone_id: string
        }
        Insert: {
          aisle: string
          bin: string
          capacity?: number | null
          current_qty?: number
          fill_state?: Database["public"]["Enums"]["warehouse_bin_fill"]
          id?: string
          updated_at?: string
          zone_id: string
        }
        Update: {
          aisle?: string
          bin?: string
          capacity?: number | null
          current_qty?: number
          fill_state?: Database["public"]["Enums"]["warehouse_bin_fill"]
          id?: string
          updated_at?: string
          zone_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "warehouse_bins_zone_id_fkey"
            columns: ["zone_id"]
            isOneToOne: false
            referencedRelation: "warehouse_zones"
            referencedColumns: ["id"]
          },
        ]
      }
      warehouse_zones: {
        Row: {
          id: string
          name: string
          sort_order: number
          warehouse_id: string
        }
        Insert: {
          id?: string
          name: string
          sort_order?: number
          warehouse_id: string
        }
        Update: {
          id?: string
          name?: string
          sort_order?: number
          warehouse_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "warehouse_zones_warehouse_id_fkey"
            columns: ["warehouse_id"]
            isOneToOne: false
            referencedRelation: "warehouses"
            referencedColumns: ["id"]
          },
        ]
      }
      warehouses: {
        Row: {
          active: boolean
          address: string | null
          code: string
          company_id: string
          created_at: string
          id: string
          name: string
          updated_at: string
        }
        Insert: {
          active?: boolean
          address?: string | null
          code: string
          company_id: string
          created_at?: string
          id?: string
          name: string
          updated_at?: string
        }
        Update: {
          active?: boolean
          address?: string | null
          code?: string
          company_id?: string
          created_at?: string
          id?: string
          name?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "warehouses_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      mv_effective_prices: {
        Row: {
          currency: string | null
          customer_id: string | null
          min_qty: number | null
          priority: number | null
          scope: Database["public"]["Enums"]["price_list_scope"] | null
          unit_price: number | null
          valid_from: string | null
          valid_to: string | null
          variant_id: string | null
          vendor_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "price_lists_vendor_company_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prices_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      secure_effective_prices: {
        Row: {
          currency: string | null
          customer_id: string | null
          min_qty: number | null
          priority: number | null
          scope: Database["public"]["Enums"]["price_list_scope"] | null
          unit_price: number | null
          valid_from: string | null
          valid_to: string | null
          variant_id: string | null
          vendor_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "price_lists_vendor_company_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prices_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      user_companies: {
        Row: {
          company_id: string | null
          role: Database["public"]["Enums"]["user_role"] | null
          type: Database["public"]["Enums"]["company_type"] | null
          user_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "company_users_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "company_users_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          created_at: string | null
          email: string | null
          id: string | null
          locale: string | null
        }
        Insert: {
          created_at?: string | null
          email?: string | null
          id?: string | null
          locale?: never
        }
        Update: {
          created_at?: string | null
          email?: string | null
          id?: string | null
          locale?: never
        }
        Relationships: []
      }
      v_vendor_orders: {
        Row: {
          created_at: string | null
          order_id: string | null
          order_number: string | null
          status: Database["public"]["Enums"]["order_status"] | null
          vendor_company_id: string | null
          vendor_total: number | null
        }
        Relationships: [
          {
            foreignKeyName: "order_items_vendor_company_id_fkey"
            columns: ["vendor_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      admin_list_company_users: {
        Args: { p_company_id?: string }
        Returns: {
          banned_until: string
          company_id: string
          company_name: string
          company_type: Database["public"]["Enums"]["company_type"]
          email: string
          full_name: string
          invited_at: string
          last_sign_in_at: string
          role: Database["public"]["Enums"]["user_role"]
          status: string
          user_id: string
        }[]
      }
      admin_set_user_role: {
        Args: {
          p_active?: boolean
          p_actor?: string
          p_company_id: string
          p_reason?: string
          p_role: Database["public"]["Enums"]["user_role"]
          p_user_id: string
        }
        Returns: undefined
      }
      auth_company_id: { Args: never; Returns: string }
      auth_role: {
        Args: never
        Returns: Database["public"]["Enums"]["user_role"]
      }
      is_role: { Args: { target: string }; Returns: boolean }
      list_order_recipients: {
        Args: { p_order_id: string }
        Returns: {
          user_id: string
        }[]
      }
      order_has_vendor: {
        Args: { p_order_id: string; p_vendor: string }
        Returns: boolean
      }
      order_item_customer_guard: {
        Args: { p_order_id: string }
        Returns: boolean
      }
      refresh_mv_effective_prices: { Args: never; Returns: undefined }
      rpc_company_catalog: {
        Args: { p_company: string }
        Returns: {
          active: boolean
          category_id: string
          description: Json
          has_price: boolean
          in_stock: boolean
          lead_time: number
          moq: number
          name: Json
          pack_size: number
          product_id: string
          sku: string
          uom: string
          variant_id: string
          vendor_company_id: string
        }[]
      }
      rpc_create_draft: { Args: never; Returns: string }
      rpc_effective_price: {
        Args: { p_customer: string; p_qty: number; p_variant: string }
        Returns: {
          currency: string
          price_list_scope: Database["public"]["Enums"]["price_list_scope"]
          unit_price: number
          vendor_id: string
        }[]
      }
      rpc_resolve_price: {
        Args: { p_company: string; p_qty: number; p_variant: string }
        Returns: {
          currency: string
          price_list_scope: Database["public"]["Enums"]["price_list_scope"]
          unit_price: number
          vendor_id: string
        }[]
      }
      rpc_submit_order: { Args: { p_order_id: string }; Returns: string }
      rpc_upsert_prices: {
        Args: { p_rows: Json; p_vendor: string }
        Returns: number
      }
      show_limit: { Args: never; Returns: number }
      show_trgm: { Args: { "": string }; Returns: string[] }
    }
    Enums: {
      company_status: "pending" | "active" | "suspended" | "rejected"
      company_type: "admin" | "vendor" | "customer"
      cost_center_status: "active" | "archived"
      order_status:
        | "draft"
        | "placed"
        | "confirmed"
        | "picking"
        | "shipped"
        | "delivered"
        | "cancelled"
      payment_terms_code:
        | "net_30"
        | "net_45"
        | "net_60"
        | "due_on_receipt"
        | "two_ten_net_30"
      price_list_scope: "global" | "customer"
      shipment_status:
        | "pending"
        | "ready"
        | "in_transit"
        | "delivered"
        | "cancelled"
      support_ticket_priority: "high" | "medium" | "low"
      support_ticket_status: "open" | "pending" | "closed"
      user_role:
        | "admin"
        | "vendor_admin"
        | "vendor_user"
        | "customer_admin"
        | "buyer"
      warehouse_bin_fill: "empty" | "partial" | "full"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      company_status: ["pending", "active", "suspended", "rejected"],
      company_type: ["admin", "vendor", "customer"],
      cost_center_status: ["active", "archived"],
      order_status: [
        "draft",
        "placed",
        "confirmed",
        "picking",
        "shipped",
        "delivered",
        "cancelled",
      ],
      payment_terms_code: [
        "net_30",
        "net_45",
        "net_60",
        "due_on_receipt",
        "two_ten_net_30",
      ],
      price_list_scope: ["global", "customer"],
      shipment_status: [
        "pending",
        "ready",
        "in_transit",
        "delivered",
        "cancelled",
      ],
      support_ticket_priority: ["high", "medium", "low"],
      support_ticket_status: ["open", "pending", "closed"],
      user_role: [
        "admin",
        "vendor_admin",
        "vendor_user",
        "customer_admin",
        "buyer",
      ],
      warehouse_bin_fill: ["empty", "partial", "full"],
    },
  },
} as const

