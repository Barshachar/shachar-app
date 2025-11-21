export const Constants = {
    public: {
        Enums: {
            company_status: ["pending", "active", "suspended", "rejected"],
            company_type: ["admin", "vendor", "customer"],
            order_status: [
                "draft",
                "placed",
                "confirmed",
                "picking",
                "shipped",
                "delivered",
                "cancelled",
            ],
            price_list_scope: ["global", "customer"],
            shipment_status: [
                "pending",
                "ready",
                "in_transit",
                "delivered",
                "cancelled",
            ],
            user_role: [
                "admin",
                "vendor_admin",
                "vendor_user",
                "customer_admin",
                "buyer",
            ],
        },
    },
};
