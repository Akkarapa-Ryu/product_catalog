# product_catalog
แบบทดสอบสำหรับการสมัครงาน Mobile Developer (Flutter) | บริษัท นิลิคอน (ประเทศไทย) จำกัด


## Project Structure

```text
product_catalog/
│
├── android/
├── ios/
├── web/
├── windows/
├── test/
├── assets/
│
├── lib/
│   │
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart
│   │   │
│   │   └── network/
│   │       └── dio_client.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── product_model.dart
│   │   │   └── product_response.dart
│   │   │
│   │   └── repositories/
│   │       └── product_repository.dart
│   │
│   ├── providers/
│   │   ├── product_provider.dart
│   │   ├── product_pagination_provider.dart
│   │   └── cart_provider.dart
│   │
│   └── features/
│       └── products/
│           ├── pages/
│           │   ├── product_list_page.dart
│           │   ├── product_detail_page.dart
│           │   └── search_filter_page.dart
│           │
│           └── widgets/
│               ├── product_grid.dart
│               ├── product_card.dart
│               ├── category_selector.dart
│               ├── loading_widget.dart
│               ├── error_widget.dart
│               └── empty_widget.dart
│
└── pubspec.yaml
```

### File Descriptions

#### 1. Core
จัดเก็บการตั้งค่าพื้นฐานและส่วนกลางของระบบ

- `api_constants.dart` — กำหนดค่าคงที่ที่เกี่ยวข้องกับ API เช่น Base URL และ Endpoint
- `dio_client.dart` — สร้างและตั้งค่า Dio Client สำหรับจัดการ HTTP Requests และการเชื่อมต่อ API

#### 2. Data
จัดการโครงสร้างข้อมูลและการเข้าถึงข้อมูลจาก API

**Models**
- `product_model.dart` — กำหนดโครงสร้างข้อมูลสินค้า เช่น ID, Title, Price, Description, Category และ Rating
- `product_response.dart` — กำหนดโครงสร้าง Response จาก API เช่น Products, Total, Skip และ Limit

**Repositories**
- `product_repository.dart` — เป็นตัวกลางในการเรียก API และแปลงข้อมูลจาก API ให้อยู่ในรูปแบบ Model ที่แอปพลิเคชันนำไปใช้งานได้

#### 3. Providers
จัดการ State Management ด้วย Riverpod และเชื่อมต่อระหว่าง UI กับ Repository

- `product_provider.dart` — ประกาศ Provider สำหรับ Repository และการดึงข้อมูลสินค้า เช่น รายละเอียดสินค้าและหมวดหมู่
- `product_pagination_provider.dart` — จัดการ State ของรายการสินค้า รวมถึง Pagination, Load More, Pull-to-Refresh, Search และ Category
- `cart_provider.dart` — จัดการ State ของตะกร้าสินค้า เช่น การเพิ่มสินค้า การลบสินค้า และจำนวนสินค้าในตะกร้า

#### 4. Features / Products
จัดเก็บหน้าจอและ UI Components ที่เกี่ยวข้องกับสินค้า

**Pages**
- `product_list_page.dart` — หน้ารายการสินค้า แสดงสินค้าในรูปแบบ Grid พร้อมระบบค้นหาและเลือกหมวดหมู่
- `product_detail_page.dart` — หน้าแสดงรายละเอียดสินค้าแต่ละรายการ
- `search_filter_page.dart` — หน้าค้นหาและกรองสินค้า โดยเลือกคำค้นหาหรือหมวดหมู่สินค้า

**Widgets**
- `product_grid.dart` — แสดงสินค้าในรูปแบบ Grid และปรับจำนวนคอลัมน์ตามขนาดหน้าจอ
- `product_card.dart` — แสดงข้อมูลสินค้าแต่ละรายการในรูปแบบ Card
- `category_selector.dart` — แสดงตัวเลือกหมวดหมู่สินค้า
- `loading_widget.dart` — แสดงสถานะ Loading ระหว่างรอข้อมูล
- `error_widget.dart` — แสดงข้อความเมื่อเกิดข้อผิดพลาด พร้อมปุ่ม Retry
- `empty_widget.dart` — แสดงข้อความเมื่อไม่มีข้อมูลสินค้าที่ตรงกับเงื่อนไข

#### 5. Root Files

- `main.dart` — จุดเริ่มต้นการทำงานของแอปพลิเคชัน
- `app.dart` — กำหนดโครงสร้างหลักของแอปพลิเคชัน เช่น MaterialApp และ Theme
- `pubspec.yaml` — กำหนด Dependencies, Assets, Fonts และการตั้งค่าของ Flutter Project