# Category Structure - Visual Guide

**Date**: March 3, 2026

---

## 📊 CATEGORY HIERARCHY

```
┌─────────────────────────────────────────────────────────────────┐
│                    OMOIKANE CAFETERIA MENU                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Daily Specials] [Breakfast] [Lunch] [Dinner] [Snacks]        │
│  [Beverages] [Desserts]                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🍽️ ITEMS BY CATEGORY

### 1️⃣ DAILY SPECIALS (6 items)
```
Daily Specials
├── Pizza
│   ├── Margherita Pizza (₹250)
│   └── Pepperoni Pizza (₹280)
├── Burger
│   ├── Chicken Burger (₹200)
│   └── Veggie Burger (₹180)
├── Biryani
│   ├── Chicken Biryani (₹280)
│   └── Mutton Biryani (₹320)
├── Paneer
│   ├── Paneer Tikka (₹180)
│   └── Paneer Butter Masala (₹220)
├── Chicken
│   ├── Tandoori Chicken (₹250)
│   └── Butter Chicken (₹240)
└── Juice
    ├── Orange Juice (₹80)
    └── Mango Juice (₹90)
```

### 2️⃣ BREAKFAST (7 items)
```
Breakfast
├── Idli
│   ├── Plain Idli (₹80)
│   └── Masala Idli (₹100)
├── Vada
│   ├── Medu Vada (₹60)
│   └── Crispy Vada (₹70)
├── Dosa
│   ├── Plain Dosa (₹100)
│   └── Masala Dosa (₹120)
├── Paratha
│   ├── Aloo Paratha (₹120)
│   └── Paneer Paratha (₹140)
├── Samosa
│   ├── Potato Samosa (₹50)
│   └── Paneer Samosa (₹60)
├── Chai
│   ├── Chai - Small (₹40)
│   └── Chai - Large (₹60)
└── Juice
    ├── Orange Juice (₹80)
    └── Mango Juice (₹90)
```

### 3️⃣ LUNCH (12 items)
```
Lunch
├── Pizza
│   ├── Margherita Pizza (₹250)
│   └── Pepperoni Pizza (₹280)
├── Burger
│   ├── Chicken Burger (₹200)
│   └── Veggie Burger (₹180)
├── Noodles
│   ├── Chow Mein (₹150)
│   └── Hakka Noodles (₹160)
├── Biryani
│   ├── Chicken Biryani (₹280)
│   └── Mutton Biryani (₹320)
├── Idli
│   ├── Plain Idli (₹80)
│   └── Masala Idli (₹100)
├── Dosa
│   ├── Plain Dosa (₹100)
│   └── Masala Dosa (₹120)
├── Paratha
│   ├── Aloo Paratha (₹120)
│   └── Paneer Paratha (₹140)
├── Paneer
│   ├── Paneer Tikka (₹180)
│   └── Paneer Butter Masala (₹220)
├── Samosa
│   ├── Potato Samosa (₹50)
│   └── Paneer Samosa (₹60)
├── Chicken
│   ├── Tandoori Chicken (₹250)
│   └── Butter Chicken (₹240)
├── Naan
│   ├── Butter Naan (₹60)
│   └── Garlic Naan (₹70)
└── Dal
    ├── Dal Makhani (₹120)
    └── Dal Tadka (₹100)
```

### 4️⃣ DINNER (8 items)
```
Dinner
├── Pizza
│   ├── Margherita Pizza (₹250)
│   └── Pepperoni Pizza (₹280)
├── Burger
│   ├── Chicken Burger (₹200)
│   └── Veggie Burger (₹180)
├── Noodles
│   ├── Chow Mein (₹150)
│   └── Hakka Noodles (₹160)
├── Biryani
│   ├── Chicken Biryani (₹280)
│   └── Mutton Biryani (₹320)
├── Paneer
│   ├── Paneer Tikka (₹180)
│   └── Paneer Butter Masala (₹220)
├── Chicken
│   ├── Tandoori Chicken (₹250)
│   └── Butter Chicken (₹240)
├── Naan
│   ├── Butter Naan (₹60)
│   └── Garlic Naan (₹70)
└── Dal
    ├── Dal Makhani (₹120)
    └── Dal Tadka (₹100)
```

### 5️⃣ SNACKS (5 items)
```
Snacks
├── Noodles
│   ├── Chow Mein (₹150)
│   └── Hakka Noodles (₹160)
├── Vada
│   ├── Medu Vada (₹60)
│   └── Crispy Vada (₹70)
├── Dosa
│   ├── Plain Dosa (₹100)
│   └── Masala Dosa (₹120)
├── Samosa
│   ├── Potato Samosa (₹50)
│   └── Paneer Samosa (₹60)
└── Chai
    ├── Chai - Small (₹40)
    └── Chai - Large (₹60)
```

### 6️⃣ BEVERAGES (2 items)
```
Beverages
├── Chai
│   ├── Chai - Small (₹40)
│   └── Chai - Large (₹60)
└── Juice
    ├── Orange Juice (₹80)
    └── Mango Juice (₹90)
```

### 7️⃣ DESSERTS (0 items)
```
Desserts
(Empty - ready for future items)
```

---

## 🔄 MULTI-CATEGORY ITEMS

Items that appear in multiple categories:

| Item | Categories | Count |
|------|-----------|-------|
| Pizza | Daily Specials, Lunch, Dinner | 3 |
| Burger | Daily Specials, Lunch, Dinner | 3 |
| Noodles | Lunch, Dinner, Snacks | 3 |
| Biryani | Daily Specials, Lunch, Dinner | 3 |
| Idli | Breakfast, Lunch, Snacks | 3 |
| Vada | Breakfast, Snacks | 2 |
| Dosa | Breakfast, Lunch, Snacks | 3 |
| Paratha | Breakfast, Lunch | 2 |
| Paneer | Daily Specials, Lunch, Dinner | 3 |
| Samosa | Breakfast, Snacks | 2 |
| Chicken | Daily Specials, Lunch, Dinner | 3 |
| Naan | Lunch, Dinner | 2 |
| Chai | Breakfast, Snacks, Beverages | 3 |
| Juice | Daily Specials, Breakfast, Beverages | 3 |
| Dal | Lunch, Dinner | 2 |

---

## 📈 STATISTICS

### By Category
| Category | Items | Variants |
|----------|-------|----------|
| Daily Specials | 6 | 12 |
| Breakfast | 7 | 14 |
| Lunch | 12 | 24 |
| Dinner | 8 | 16 |
| Snacks | 5 | 10 |
| Beverages | 2 | 4 |
| Desserts | 0 | 0 |
| **TOTAL** | **15** | **30** |

### By Food Type
| Food Type | Count |
|-----------|-------|
| VEG | 11 |
| NON_VEG | 4 |
| **TOTAL** | **15** |

### By Canteen
| Canteen | Items |
|---------|-------|
| Main Canteen | 30 |
| North Wing | 30 |
| South Wing | 30 |
| Cafeteria | 30 |
| **TOTAL** | **120** |

---

## 💰 PRICE RANGES

### By Canteen (Main Canteen Prices)

**Cheapest Items:**
- Chai (Small): ₹40
- Potato Samosa: ₹50
- Medu Vada: ₹60
- Butter Naan: ₹60

**Mid-Range Items:**
- Plain Idli: ₹80
- Orange Juice: ₹80
- Plain Dosa: ₹100
- Masala Idli: ₹100
- Chow Mein: ₹150

**Premium Items:**
- Paneer Tikka: ₹180
- Chicken Burger: ₹200
- Tandoori Chicken: ₹250
- Margherita Pizza: ₹250
- Chicken Biryani: ₹280
- Pepperoni Pizza: ₹280
- Mutton Biryani: ₹320

---

## 🎯 USAGE EXAMPLES

### Example 1: User Wants Breakfast
1. Click "Breakfast" tab
2. See 7 base dishes
3. Click "Idli"
4. See 2 variants: Plain Idli, Masala Idli
5. See prices from all 4 canteens
6. Select one and order

### Example 2: User Wants Quick Snack
1. Click "Snacks" tab
2. See 5 base dishes
3. Click "Samosa"
4. See 2 variants: Potato, Paneer
5. See prices from all 4 canteens
6. Select one and order

### Example 3: User Wants Special Item
1. Click "Daily Specials" tab
2. See 6 base dishes
3. Click "Pizza"
4. See 2 variants: Margherita, Pepperoni
5. See prices from all 4 canteens
6. Select one and order

### Example 4: User Wants Lunch
1. Click "Lunch" tab
2. See 12 base dishes
3. Click "Biryani"
4. See 2 variants: Chicken, Mutton
5. See prices from all 4 canteens
6. Select one and order

---

## 🔍 SEARCH EXAMPLES

### Search "Pizza"
**Results:**
- Margherita Pizza (₹250)
- Pepperoni Pizza (₹280)

**Available in:**
- Main Canteen
- North Wing Canteen
- South Wing Canteen
- Cafeteria

**Categories:**
- Daily Specials
- Lunch
- Dinner

### Search "Chai"
**Results:**
- Chai - Small (₹40)
- Chai - Large (₹60)

**Available in:**
- Main Canteen
- North Wing Canteen
- South Wing Canteen
- Cafeteria

**Categories:**
- Breakfast
- Snacks
- Beverages

---

## 📱 FRONTEND DISPLAY

### Tab Order (Left to Right)
```
[Daily Specials] [Breakfast] [Lunch] [Dinner] [Snacks] [Beverages] [Desserts]
```

### When User Clicks "Daily Specials"
```
┌─────────────────────────────────────────┐
│ Daily Specials                          │
├─────────────────────────────────────────┤
│ [Pizza]      [Burger]    [Biryani]      │
│ [Paneer]     [Chicken]   [Juice]        │
└─────────────────────────────────────────┘
```

### When User Clicks "Pizza"
```
┌──────────────────────────────────────────────────┐
│ Available at                                     │
├──────────────────────────────────────────────────┤
│ Margherita Pizza - Main Canteen - ₹250          │
│ Margherita Pizza - North Wing - ₹240            │
│ Margherita Pizza - South Wing - ₹260            │
│ Margherita Pizza - Cafeteria - ₹220             │
│ Pepperoni Pizza - Main Canteen - ₹280           │
│ Pepperoni Pizza - North Wing - ₹270             │
│ Pepperoni Pizza - South Wing - ₹290             │
│ Pepperoni Pizza - Cafeteria - ₹250              │
└──────────────────────────────────────────────────┘
```

---

## ✅ VERIFICATION CHECKLIST

- [ ] Categories appear in correct order
- [ ] Daily Specials is first
- [ ] Breakfast is second
- [ ] All 7 categories visible
- [ ] Clicking each category shows correct items
- [ ] Multi-category items appear in all their categories
- [ ] Prices display correctly
- [ ] Variants display correctly
- [ ] All 4 canteens show for each item
- [ ] Search works correctly

---

**Status**: ✅ Ready  
**Date**: March 3, 2026  
**Version**: 1.0.0

