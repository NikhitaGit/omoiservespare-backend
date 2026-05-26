-- =========================
-- INSERT SEED DATA
-- =========================

-- Insert Categories
INSERT INTO categories (name, is_active) VALUES
('Breakfast', true),
('Lunch', true),
('Dinner', true),
('Snacks', true),
('Beverages', true),
('Daily Specials', true)
ON CONFLICT DO NOTHING;

-- Insert Base Dishes
INSERT INTO base_dishes (name, food_type, default_image_url, is_active) VALUES
('Biryani', 'VEG', 'https://example.com/biryani.jpg', true),
('Butter Chicken', 'NON_VEG', 'https://example.com/butter-chicken.jpg', true),
('Paneer Tikka', 'VEG', 'https://example.com/paneer-tikka.jpg', true),
('Tandoori Chicken', 'NON_VEG', 'https://example.com/tandoori-chicken.jpg', true),
('Dal Makhani', 'VEG', 'https://example.com/dal-makhani.jpg', true),
('Samosa', 'VEG', 'https://example.com/samosa.jpg', true),
('Naan', 'VEG', 'https://example.com/naan.jpg', true),
('Chai', 'VEG', 'https://example.com/chai.jpg', true)
ON CONFLICT DO NOTHING;

-- Insert Dishes (Variants)
INSERT INTO dishes (base_dish_id, name, is_active) VALUES
(1, 'Chicken Biryani', true),
(1, 'Mutton Biryani', true),
(1, 'Vegetable Biryani', true),
(2, 'Butter Chicken - Regular', true),
(2, 'Butter Chicken - Spicy', true),
(3, 'Paneer Tikka - Mild', true),
(3, 'Paneer Tikka - Hot', true),
(4, 'Tandoori Chicken - Half', true),
(4, 'Tandoori Chicken - Full', true),
(5, 'Dal Makhani - Regular', true),
(6, 'Samosa - 2 Pieces', true),
(6, 'Samosa - 4 Pieces', true),
(7, 'Butter Naan', true),
(7, 'Garlic Naan', true),
(8, 'Chai - Small', true),
(8, 'Chai - Large', true)
ON CONFLICT DO NOTHING;

-- Insert Canteens
INSERT INTO canteens (name, place, prep_time, rating, image_url, is_active) VALUES
('Main Canteen', 'Building A', '30 mins', 4.5, 'https://example.com/canteen1.jpg', true),
('North Wing Canteen', 'Building B', '25 mins', 4.2, 'https://example.com/canteen2.jpg', true),
('South Wing Canteen', 'Building C', '35 mins', 4.8, 'https://example.com/canteen3.jpg', true),
('Cafeteria', 'Ground Floor', '20 mins', 4.0, 'https://example.com/canteen4.jpg', true)
ON CONFLICT DO NOTHING;

-- Insert Menu Items (Canteen 1 - Main Canteen)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(1, 1, 250.00, true, 30),
(1, 2, 280.00, true, 30),
(1, 3, 200.00, true, 25),
(1, 4, 320.00, true, 35),
(1, 5, 350.00, true, 35),
(1, 6, 180.00, true, 20),
(1, 7, 200.00, true, 20),
(1, 8, 150.00, true, 15),
(1, 9, 200.00, true, 15),
(1, 10, 220.00, true, 25),
(1, 11, 40.00, true, 10),
(1, 12, 70.00, true, 10),
(1, 13, 60.00, true, 5),
(1, 14, 70.00, true, 5),
(1, 15, 30.00, true, 5),
(1, 16, 50.00, true, 5)
ON CONFLICT DO NOTHING;

-- Insert Menu Items (Canteen 2 - North Wing)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(2, 1, 240.00, true, 25),
(2, 2, 270.00, true, 28),
(2, 3, 190.00, true, 22),
(2, 4, 310.00, true, 32),
(2, 5, 340.00, true, 32),
(2, 6, 170.00, true, 18),
(2, 7, 190.00, true, 18),
(2, 8, 140.00, true, 12),
(2, 9, 190.00, true, 12),
(2, 10, 210.00, true, 22),
(2, 11, 35.00, true, 8),
(2, 12, 65.00, true, 8),
(2, 13, 55.00, true, 3),
(2, 14, 65.00, true, 3),
(2, 15, 25.00, true, 3),
(2, 16, 45.00, true, 3)
ON CONFLICT DO NOTHING;

-- Insert Menu Items (Canteen 3 - South Wing)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(3, 1, 260.00, true, 35),
(3, 2, 290.00, true, 35),
(3, 3, 210.00, true, 28),
(3, 4, 330.00, true, 38),
(3, 5, 360.00, true, 38),
(3, 6, 190.00, true, 25),
(3, 7, 210.00, true, 25),
(3, 8, 160.00, true, 18),
(3, 9, 210.00, true, 18),
(3, 10, 230.00, true, 28),
(3, 11, 45.00, true, 12),
(3, 12, 80.00, true, 12),
(3, 13, 70.00, true, 8),
(3, 14, 80.00, true, 8),
(3, 15, 35.00, true, 8),
(3, 16, 55.00, true, 8)
ON CONFLICT DO NOTHING;

-- Insert Menu Items (Canteen 4 - Cafeteria)
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(4, 1, 220.00, true, 20),
(4, 2, 250.00, true, 20),
(4, 3, 170.00, true, 15),
(4, 4, 290.00, true, 20),
(4, 5, 320.00, true, 20),
(4, 6, 150.00, true, 10),
(4, 7, 170.00, true, 10),
(4, 8, 120.00, true, 8),
(4, 9, 170.00, true, 8),
(4, 10, 190.00, true, 15),
(4, 11, 30.00, true, 5),
(4, 12, 55.00, true, 5),
(4, 13, 45.00, true, 2),
(4, 14, 55.00, true, 2),
(4, 15, 20.00, true, 2),
(4, 16, 35.00, true, 2)
ON CONFLICT DO NOTHING;

-- Link Base Dishes to Categories
INSERT INTO base_dish_categories (base_dish_id, category_id) VALUES
(1, 2), -- Biryani -> Lunch
(2, 2), -- Butter Chicken -> Lunch
(3, 2), -- Paneer Tikka -> Lunch
(4, 2), -- Tandoori Chicken -> Lunch
(5, 2), -- Dal Makhani -> Lunch
(6, 4), -- Samosa -> Snacks
(7, 2), -- Naan -> Lunch
(8, 5)  -- Chai -> Beverages
ON CONFLICT DO NOTHING;
