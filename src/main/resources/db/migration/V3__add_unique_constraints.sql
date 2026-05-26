-- =========================
-- ADD UNIQUE CONSTRAINTS
-- =========================

-- Add unique constraint on canteen name to prevent duplicates
ALTER TABLE canteens ADD CONSTRAINT unique_canteen_name UNIQUE (name);

-- Add unique constraint on category name
ALTER TABLE categories ADD CONSTRAINT unique_category_name UNIQUE (name);

-- Add unique constraint on base dish name
ALTER TABLE base_dishes ADD CONSTRAINT unique_base_dish_name UNIQUE (name);
