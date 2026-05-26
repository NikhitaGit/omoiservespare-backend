# Custom Changes Made to V4 Migration

**Date**: March 3, 2026

---

## ✅ Changes Applied

### 1. Vada - Only in Canteen 2
- **Removed from**: Canteen 1, Canteen 3, Canteen 4
- **Available in**: Canteen 2 (North Wing Canteen) only
- **Variants**: Medu Vada, Crispy Vada
- **Prices**: ₹55, ₹65 (Canteen 2)

### 2. Paratha - Only in Canteen 4
- **Removed from**: Canteen 1, Canteen 2, Canteen 3
- **Available in**: Canteen 4 (Cafeteria) only
- **Variants**: Aloo Paratha, Paneer Paratha
- **Prices**: ₹110, ₹130 (Canteen 4)

### 3. Desserts Added (EGG Food Type)
Added 3 new base dishes with egg-based desserts:

**Cake (Base Dish 16)**
- Variants: Chocolate Cake, Vanilla Cake
- Food Type: EGG
- Categories: Desserts, Daily Specials
- Prices: ₹150, ₹160 (Canteen 1)

**Pastry (Base Dish 17)**
- Variants: Chocolate Pastry, Almond Pastry
- Food Type: EGG
- Categories: Desserts, Daily Specials
- Prices: ₹140, ₹150 (Canteen 1)

**Brownie (Base Dish 18)**
- Variants: Chocolate Brownie, Walnut Brownie
- Food Type: EGG
- Categories: Desserts, Daily Specials
- Prices: ₹130, ₹140 (Canteen 1)

---

## 📊 Updated Statistics

### Base Dishes
- **Old**: 15 dishes
- **New**: 18 dishes (added 3 desserts)

### Dish Variants
- **Old**: 30 variants
- **New**: 36 variants (added 6 dessert variants)

### Menu Items
- **Old**: 120 items (30 × 4 canteens)
- **New**: 132 items (36 × 4 canteens, minus Vada from 3 canteens, minus Paratha from 3 canteens)

### Categories
- **Desserts**: Now has 3 items (Cake, Pastry, Brownie)
- **Daily Specials**: Now includes desserts

---

## 🍰 Dessert Availability

### All Canteens Have Desserts
- Canteen 1 (Main Canteen): All 6 dessert variants
- Canteen 2 (North Wing): All 6 dessert variants
- Canteen 3 (South Wing): All 6 dessert variants
- Canteen 4 (Cafeteria): All 6 dessert variants

---

## 📋 Canteen-Specific Items

### Canteen 1 (Main Canteen)
- ✅ Has: Pizza, Burger, Noodles, Biryani, Idli, Dosa, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal, Cake, Pastry, Brownie
- ❌ Missing: Vada, Paratha

### Canteen 2 (North Wing)
- ✅ Has: Pizza, Burger, Noodles, Biryani, Idli, **Vada**, Dosa, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal, Cake, Pastry, Brownie
- ❌ Missing: Paratha

### Canteen 3 (South Wing)
- ✅ Has: Pizza, Burger, Noodles, Biryani, Idli, Dosa, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal, Cake, Pastry, Brownie
- ❌ Missing: Vada, Paratha

### Canteen 4 (Cafeteria)
- ✅ Has: Pizza, Burger, Noodles, Biryani, Idli, Dosa, **Paratha**, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal, Cake, Pastry, Brownie
- ❌ Missing: Vada

---

## 💰 Dessert Pricing

### Canteen 1 (Main Canteen)
- Chocolate Cake: ₹150
- Vanilla Cake: ₹160
- Chocolate Pastry: ₹140
- Almond Pastry: ₹150
- Chocolate Brownie: ₹130
- Walnut Brownie: ₹140

### Canteen 2 (North Wing)
- Chocolate Cake: ₹140
- Vanilla Cake: ₹150
- Chocolate Pastry: ₹130
- Almond Pastry: ₹140
- Chocolate Brownie: ₹120
- Walnut Brownie: ₹130

### Canteen 3 (South Wing)
- Chocolate Cake: ₹160
- Vanilla Cake: ₹170
- Chocolate Pastry: ₹150
- Almond Pastry: ₹160
- Chocolate Brownie: ₹140
- Walnut Brownie: ₹150

### Canteen 4 (Cafeteria)
- Chocolate Cake: ₹120
- Vanilla Cake: ₹130
- Chocolate Pastry: ₹110
- Almond Pastry: ₹120
- Chocolate Brownie: ₹100
- Walnut Brownie: ₹110

---

## 🎯 Frontend Display

### Desserts Category
When user clicks "Desserts" tab, they will see:
- Cake (Chocolate, Vanilla)
- Pastry (Chocolate, Almond)
- Brownie (Chocolate, Walnut)

All available in all 4 canteens with different prices.

### Daily Specials Category
Now includes desserts along with other items:
- Pizza, Burger, Biryani, Paneer, Chicken, Juice, **Cake, Pastry, Brownie**

---

## ✅ Ready to Apply

The V4 migration file is now updated with all your custom changes. Simply restart Spring Boot:

```bash
cd omoiservespare
mvn spring-boot:run
```

Flyway will automatically apply all changes!

---

## 📝 Notes

- Vada is specialty item only in Canteen 2
- Paratha is specialty item only in Canteen 4
- Desserts are available in all canteens
- All desserts are EGG food type
- Desserts appear in both "Desserts" and "Daily Specials" categories

---

**Status**: ✅ Ready to Apply  
**Date**: March 3, 2026

