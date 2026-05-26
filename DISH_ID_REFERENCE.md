# Dish ID Reference - V4 Migration

**Date**: March 3, 2026

---

## 📋 Complete Dish ID Mapping

### Base Dishes (18 total)
| ID | Base Dish | Food Type |
|----|-----------|-----------|
| 1 | Pizza | VEG |
| 2 | Burger | NON_VEG |
| 3 | Noodles | VEG |
| 4 | Biryani | NON_VEG |
| 5 | Idli | VEG |
| 6 | Vada | VEG |
| 7 | Dosa | VEG |
| 8 | Paratha | VEG |
| 9 | Paneer | VEG |
| 10 | Samosa | VEG |
| 11 | Chicken | NON_VEG |
| 12 | Naan | VEG |
| 13 | Chai | VEG |
| 14 | Juice | VEG |
| 15 | Dal | VEG |
| 16 | Cake | EGG |
| 17 | Pastry | EGG |
| 18 | Brownie | EGG |

---

## 🍽️ Dish Variants (36 total)

### Pizza (Base Dish 1)
- Dish ID 1: Margherita Pizza
- Dish ID 2: Pepperoni Pizza

### Burger (Base Dish 2)
- Dish ID 3: Chicken Burger
- Dish ID 4: Veggie Burger

### Noodles (Base Dish 3)
- Dish ID 5: Chow Mein
- Dish ID 6: Hakka Noodles

### Biryani (Base Dish 4)
- Dish ID 7: Chicken Biryani
- Dish ID 8: Mutton Biryani

### Idli (Base Dish 5)
- Dish ID 9: Plain Idli
- Dish ID 10: Masala Idli

### **Vada (Base Dish 6)** ⭐ ONLY IN CANTEEN 2
- Dish ID 11: Medu Vada
- Dish ID 12: Crispy Vada

### Dosa (Base Dish 7)
- Dish ID 13: Plain Dosa
- Dish ID 14: Masala Dosa

### **Paratha (Base Dish 8)** ⭐ ONLY IN CANTEEN 4
- Dish ID 15: Aloo Paratha
- Dish ID 16: Paneer Paratha

### Paneer (Base Dish 9)
- Dish ID 17: Paneer Tikka
- Dish ID 18: Paneer Butter Masala

### Samosa (Base Dish 10)
- Dish ID 19: Potato Samosa
- Dish ID 20: Paneer Samosa

### Chicken (Base Dish 11)
- Dish ID 21: Tandoori Chicken
- Dish ID 22: Butter Chicken

### Naan (Base Dish 12)
- Dish ID 23: Butter Naan
- Dish ID 24: Garlic Naan

### Chai (Base Dish 13)
- Dish ID 25: Chai - Small
- Dish ID 26: Chai - Large

### Juice (Base Dish 14)
- Dish ID 27: Orange Juice
- Dish ID 28: Mango Juice

### Dal (Base Dish 15)
- Dish ID 29: Dal Makhani
- Dish ID 30: Dal Tadka

### Cake (Base Dish 16)
- Dish ID 31: Chocolate Cake
- Dish ID 32: Vanilla Cake

### Pastry (Base Dish 17)
- Dish ID 33: Chocolate Pastry
- Dish ID 34: Almond Pastry

### Brownie (Base Dish 18)
- Dish ID 35: Chocolate Brownie
- Dish ID 36: Walnut Brownie

---

## 🏪 Canteen Availability

### Canteen 1 (Main Canteen)
**Available Dish IDs**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
**Missing**: 11, 12 (Vada), 15, 16 (Paratha)

### Canteen 2 (North Wing)
**Available Dish IDs**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
**Missing**: 15, 16 (Paratha)
**Special**: Has Vada (11, 12)

### Canteen 3 (South Wing)
**Available Dish IDs**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
**Missing**: 11, 12 (Vada), 15, 16 (Paratha)

### Canteen 4 (Cafeteria)
**Available Dish IDs**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
**Missing**: 11, 12 (Vada)
**Special**: Has Paratha (15, 16)

---

## ✅ Verification

### Vada Check
- ✅ Dish ID 11 (Medu Vada) - ONLY in Canteen 2
- ✅ Dish ID 12 (Crispy Vada) - ONLY in Canteen 2
- ✅ NOT in Canteen 1, 3, 4

### Paratha Check
- ✅ Dish ID 15 (Aloo Paratha) - ONLY in Canteen 4
- ✅ Dish ID 16 (Paneer Paratha) - ONLY in Canteen 4
- ✅ NOT in Canteen 1, 2, 3

### Dosa Check
- ✅ Dish ID 13 (Plain Dosa) - In ALL canteens
- ✅ Dish ID 14 (Masala Dosa) - In ALL canteens

---

**Status**: ✅ Corrected  
**Date**: March 3, 2026

