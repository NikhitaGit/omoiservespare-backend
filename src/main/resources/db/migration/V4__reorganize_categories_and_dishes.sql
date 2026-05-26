-- =========================
-- REORGANIZE CATEGORIES AND DISHES
-- =========================
-- This migration reorganizes categories and dishes with proper FK relationships
-- NOTE: Does NOT delete canteens - keeps existing canteen IDs (1-4)

-- Step 0: Delete old data (in reverse dependency order) - but NOT canteens
DELETE FROM base_dish_categories;
DELETE FROM menu_items;
DELETE FROM dishes;
DELETE FROM base_dishes;
DELETE FROM categories;

-- Step 1: Insert Categories in new order
INSERT INTO categories (name, is_active) VALUES
('Daily Specials', true),
('Breakfast', true),
('Lunch', true),
('Dinner', true),
('Snacks', true),
('Beverages', true),
('Desserts', true);

-- Step 2: Insert New Base Dishes (18 items - 15 original + 3 desserts)
INSERT INTO base_dishes (name, food_type, default_image_url, is_active) VALUES
('Pizza', 'VEG', 'https://example.com/pizza.jpg', true),
('Burger', 'NON_VEG', 'https://example.com/burger.jpg', true),
('Noodles', 'VEG', 'https://example.com/noodles.jpg', true),
('Biryani', 'NON_VEG', 'https://example.com/biryani.jpg', true),
('Idli', 'VEG', 'https://example.com/idli.jpg', true),
('Vada', 'VEG', 'https://example.com/vada.jpg', true),
('Dosa', 'VEG', 'https://example.com/dosa.jpg', true),
('Paratha', 'VEG', 'https://example.com/paratha.jpg', true),
('Paneer', 'VEG', 'https://example.com/paneer.jpg', true),
('Samosa', 'VEG', 'https://example.com/samosa.jpg', true),
('Chicken', 'NON_VEG', 'https://example.com/chicken.jpg', true),
('Naan', 'VEG', 'https://example.com/naan.jpg', true),
('Chai', 'VEG', 'https://example.com/chai.jpg', true),
('Juice', 'VEG', 'https://example.com/juice.jpg', true),
('Dal', 'VEG', 'https://example.com/dal.jpg', true),
('Cake', 'EGG', 'https://example.com/cake.jpg', true),
('Pastry', 'EGG', 'https://example.com/pastry.jpg', true),
('Brownie', 'EGG', 'https://example.com/brownie.jpg', true);

-- Step 3: Insert Dishes (Variants) using base_dish names to get correct IDs
INSERT INTO dishes (base_dish_id, name, is_active) 
SELECT bd.id, v.name, true FROM base_dishes bd
CROSS JOIN (VALUES 
  ('Pizza', 'Margherita Pizza'), ('Pizza', 'Pepperoni Pizza'),
  ('Burger', 'Chicken Burger'), ('Burger', 'Veggie Burger'),
  ('Noodles', 'Chow Mein'), ('Noodles', 'Hakka Noodles'),
  ('Biryani', 'Chicken Biryani'), ('Biryani', 'Mutton Biryani'),
  ('Idli', 'Plain Idli'), ('Idli', 'Masala Idli'),
  ('Vada', 'Medu Vada'), ('Vada', 'Crispy Vada'),
  ('Dosa', 'Plain Dosa'), ('Dosa', 'Masala Dosa'),
  ('Paratha', 'Aloo Paratha'), ('Paratha', 'Paneer Paratha'),
  ('Paneer', 'Paneer Tikka'), ('Paneer', 'Paneer Butter Masala'),
  ('Samosa', 'Potato Samosa'), ('Samosa', 'Paneer Samosa'),
  ('Chicken', 'Tandoori Chicken'), ('Chicken', 'Butter Chicken'),
  ('Naan', 'Butter Naan'), ('Naan', 'Garlic Naan'),
  ('Chai', 'Chai - Small'), ('Chai', 'Chai - Large'),
  ('Juice', 'Orange Juice'), ('Juice', 'Mango Juice'),
  ('Dal', 'Dal Makhani'), ('Dal', 'Dal Tadka'),
  ('Cake', 'Chocolate Cake'), ('Cake', 'Vanilla Cake'),
  ('Pastry', 'Chocolate Pastry'), ('Pastry', 'Almond Pastry'),
  ('Brownie', 'Chocolate Brownie'), ('Brownie', 'Walnut Brownie')
) AS v(base_name, name)
WHERE bd.name = v.base_name;

-- Step 4: Link Base Dishes to Categories (Multi-category support)
INSERT INTO base_dish_categories (base_dish_id, category_id) 
SELECT bd.id, c.id FROM base_dishes bd, categories c
WHERE (bd.name = 'Pizza' AND c.name IN ('Daily Specials', 'Lunch', 'Dinner'))
   OR (bd.name = 'Burger' AND c.name IN ('Daily Specials', 'Lunch', 'Dinner'))
   OR (bd.name = 'Noodles' AND c.name IN ('Lunch', 'Dinner', 'Snacks'))
   OR (bd.name = 'Biryani' AND c.name IN ('Daily Specials', 'Lunch', 'Dinner'))
   OR (bd.name = 'Idli' AND c.name IN ('Breakfast', 'Lunch', 'Snacks'))
   OR (bd.name = 'Vada' AND c.name IN ('Breakfast', 'Snacks'))
   OR (bd.name = 'Dosa' AND c.name IN ('Breakfast', 'Lunch', 'Snacks'))
   OR (bd.name = 'Paratha' AND c.name IN ('Breakfast', 'Lunch'))
   OR (bd.name = 'Paneer' AND c.name IN ('Daily Specials', 'Lunch', 'Dinner'))
   OR (bd.name = 'Samosa' AND c.name IN ('Breakfast', 'Snacks'))
   OR (bd.name = 'Chicken' AND c.name IN ('Daily Specials', 'Lunch', 'Dinner'))
   OR (bd.name = 'Naan' AND c.name IN ('Lunch', 'Dinner'))
   OR (bd.name = 'Chai' AND c.name IN ('Breakfast', 'Snacks', 'Beverages'))
   OR (bd.name = 'Juice' AND c.name IN ('Daily Specials', 'Breakfast', 'Beverages'))
   OR (bd.name = 'Dal' AND c.name IN ('Lunch', 'Dinner'))
   OR (bd.name = 'Cake' AND c.name IN ('Desserts', 'Daily Specials'))
   OR (bd.name = 'Pastry' AND c.name IN ('Desserts', 'Daily Specials'))
   OR (bd.name = 'Brownie' AND c.name IN ('Desserts', 'Daily Specials'));

-- Step 5: Insert Menu Items for all dishes across existing 4 canteens (IDs 1-4)
-- Canteen 1 - Main Canteen (NO Vada, NO Paratha, WITH Desserts)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min)
SELECT 1, d.id, CASE WHEN bd.name IN ('Pizza', 'Burger') THEN 250.00 WHEN bd.name IN ('Noodles', 'Biryani') THEN 280.00 WHEN bd.name IN ('Idli', 'Dosa') THEN 100.00 WHEN bd.name IN ('Paneer', 'Samosa') THEN 150.00 WHEN bd.name IN ('Chicken', 'Naan') THEN 240.00 WHEN bd.name IN ('Chai', 'Juice') THEN 80.00 WHEN bd.name IN ('Dal', 'Cake', 'Pastry', 'Brownie') THEN 140.00 ELSE 100.00 END, true, CASE WHEN bd.name IN ('Pizza', 'Burger', 'Biryani') THEN 20 WHEN bd.name IN ('Noodles', 'Paneer', 'Chicken') THEN 15 ELSE 10 END
FROM dishes d
JOIN base_dishes bd ON d.base_dish_id = bd.id
WHERE bd.name NOT IN ('Vada', 'Paratha');

-- Canteen 2 - North Wing (WITH Vada, NO Paratha, WITH Desserts)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min)
SELECT 2, d.id, CASE WHEN bd.name IN ('Pizza', 'Burger') THEN 240.00 WHEN bd.name IN ('Noodles', 'Biryani') THEN 270.00 WHEN bd.name IN ('Idli', 'Dosa', 'Vada') THEN 95.00 WHEN bd.name IN ('Paneer', 'Samosa') THEN 140.00 WHEN bd.name IN ('Chicken', 'Naan') THEN 230.00 WHEN bd.name IN ('Chai', 'Juice') THEN 75.00 WHEN bd.name IN ('Dal', 'Cake', 'Pastry', 'Brownie') THEN 130.00 ELSE 100.00 END, true, CASE WHEN bd.name IN ('Pizza', 'Burger', 'Biryani') THEN 18 WHEN bd.name IN ('Noodles', 'Paneer', 'Chicken') THEN 13 ELSE 8 END
FROM dishes d
JOIN base_dishes bd ON d.base_dish_id = bd.id
WHERE bd.name NOT IN ('Paratha');

-- Canteen 3 - South Wing (NO Vada, NO Paratha, WITH Desserts)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min)
SELECT 3, d.id, CASE WHEN bd.name IN ('Pizza', 'Burger') THEN 260.00 WHEN bd.name IN ('Noodles', 'Biryani') THEN 300.00 WHEN bd.name IN ('Idli', 'Dosa') THEN 110.00 WHEN bd.name IN ('Paneer', 'Samosa') THEN 160.00 WHEN bd.name IN ('Chicken', 'Naan') THEN 260.00 WHEN bd.name IN ('Chai', 'Juice') THEN 100.00 WHEN bd.name IN ('Dal', 'Cake', 'Pastry', 'Brownie') THEN 150.00 ELSE 100.00 END, true, CASE WHEN bd.name IN ('Pizza', 'Burger', 'Biryani') THEN 22 WHEN bd.name IN ('Noodles', 'Paneer', 'Chicken') THEN 17 ELSE 12 END
FROM dishes d
JOIN base_dishes bd ON d.base_dish_id = bd.id
WHERE bd.name NOT IN ('Vada', 'Paratha');

-- Canteen 4 - Cafeteria (NO Vada, WITH Paratha, WITH Desserts)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min)
SELECT 4, d.id, CASE WHEN bd.name IN ('Pizza', 'Burger') THEN 220.00 WHEN bd.name IN ('Noodles', 'Biryani') THEN 250.00 WHEN bd.name IN ('Idli', 'Dosa', 'Paratha') THEN 110.00 WHEN bd.name IN ('Paneer', 'Samosa') THEN 120.00 WHEN bd.name IN ('Chicken', 'Naan') THEN 210.00 WHEN bd.name IN ('Chai', 'Juice') THEN 70.00 WHEN bd.name IN ('Dal', 'Cake', 'Pastry', 'Brownie') THEN 110.00 ELSE 100.00 END, true, CASE WHEN bd.name IN ('Pizza', 'Burger', 'Biryani') THEN 15 WHEN bd.name IN ('Noodles', 'Paneer', 'Chicken') THEN 12 ELSE 8 END
FROM dishes d
JOIN base_dishes bd ON d.base_dish_id = bd.id
WHERE bd.name NOT IN ('Vada');
