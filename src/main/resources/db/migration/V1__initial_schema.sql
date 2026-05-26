-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    account_type VARCHAR(50),
    phone_number VARCHAR(50)
);

-- =========================
-- REFRESH TOKENS
-- =========================
CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(500) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    expires_at TIMESTAMP,
    last_used_at TIMESTAMP,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    device_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_refresh_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- OTP
-- =========================
CREATE TABLE otps (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    otp VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

-- =========================
-- CANTEENS
-- =========================
CREATE TABLE canteens (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255),
    place VARCHAR(255),
    prep_time VARCHAR(50),
    rating NUMERIC(3,2),
    image_url VARCHAR(500),
    is_active BOOLEAN
);

-- =========================
-- CATEGORIES
-- =========================
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

-- =========================
-- BASE DISHES
-- =========================
CREATE TABLE base_dishes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    food_type VARCHAR(50) NOT NULL,
    default_image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE
);

-- =========================
-- BASE DISH <-> CATEGORY (ManyToMany)
-- =========================
CREATE TABLE base_dish_categories (
    base_dish_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (base_dish_id, category_id),
    CONSTRAINT fk_base_dish
        FOREIGN KEY (base_dish_id) REFERENCES base_dishes(id),
    CONSTRAINT fk_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- =========================
-- DISHES (Variants)
-- =========================
CREATE TABLE dishes (
    id BIGSERIAL PRIMARY KEY,
    base_dish_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_dish_base
        FOREIGN KEY (base_dish_id) REFERENCES base_dishes(id),
    CONSTRAINT unique_variant UNIQUE (base_dish_id, name)
);

-- =========================
-- MENU ITEMS
-- =========================
CREATE TABLE menu_items (
    id BIGSERIAL PRIMARY KEY,
    canteen_id BIGINT NOT NULL,
    dish_id BIGINT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    prep_min INTEGER,
    override_image_url VARCHAR(500),
    CONSTRAINT fk_menu_canteen
        FOREIGN KEY (canteen_id) REFERENCES canteens(id),
    CONSTRAINT fk_menu_dish
        FOREIGN KEY (dish_id) REFERENCES dishes(id),
    CONSTRAINT unique_menu UNIQUE (canteen_id, dish_id)
);

-- =========================
-- ORDERS
-- =========================
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(100) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    status VARCHAR(50),
    payment_status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100),
    total_amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_order_user
        FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- =========================
-- CANTEEN ORDERS
-- =========================
CREATE TABLE canteen_orders (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    canteen_id BIGINT NOT NULL,
    status VARCHAR(50),
    subtotal NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP,
    cancel_reason VARCHAR(500),
    refunded BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_parent_order
        FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_canteen
        FOREIGN KEY (canteen_id) REFERENCES canteens(id)
);

-- =========================
-- ORDER ITEMS
-- =========================
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    canteen_order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    CONSTRAINT fk_order_item
        FOREIGN KEY (canteen_order_id)
        REFERENCES canteen_orders(id)
);