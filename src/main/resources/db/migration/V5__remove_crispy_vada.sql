-- =========================
-- REMOVE CRISPY VADA VARIANT
-- =========================
-- Keep only Medu Vada, remove Crispy Vada

DELETE FROM menu_items 
WHERE dish_id IN (
    SELECT d.id 
    FROM dishes d
    JOIN base_dishes bd ON d.base_dish_id = bd.id
    WHERE bd.name = 'Vada' 
    AND d.name = 'Crispy Vada'
);

DELETE FROM dishes 
WHERE base_dish_id IN (
    SELECT id FROM base_dishes WHERE name = 'Vada'
)
AND name = 'Crispy Vada';
