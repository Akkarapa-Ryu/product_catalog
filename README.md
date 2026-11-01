# product_catalog
แบบทดสอบสำหรับการสมัครงาน Mobile Developer (Flutter) | บริษัท นิลิคอน (ประเทศไทย) จำกัด


product_catalog/
│
├── android/
├── ios/
├── web/
├── windows/
├── test/
│
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
│   │   │   ├── product_model.dart -> กำหนดโครงสร้างข้อมูลสินค้า
│   │   │   └── product_response.dart -> กำหนดโครงสร้าง Response จาก API
│   │   │
│   │   └── repositories/
│   │       └── product_repository.dart -> เป็นตัวกลางในการเรียก API และแปลงข้อมูลจาก API ให้เป็น Model ที่แอปนำไปใช้งานได้
│   │
│   ├── providers/ -> จัดการ State Management ด้วย Riverpod + รับผิดชอบการจัดการ State และเชื่อมต่อระหว่าง UI กับ Repository
│   │   ├── product_provider.dart -> ประกาศ Provider สำหรับ Repository และการดึงข้อมูลสินค้า เช่น รายละเอียดสินค้าและหมวดหมู่
│   │   ├── product_pagination_provider.dart -> จัดการ State ของรายการสินค้า รวมถึง Pagination, Load More, Refresh, Search และ Category
│   │   └── cart_provider.dart -> จัดการ State ของตะกร้าสินค้า เช่น การเพิ่มสินค้า การลบสินค้า และจำนวนสินค้าในตะกร้า
│   │
│   └── features/
│       └── products/
│           ├── pages/
│           │   ├── product_list_page.dart -> หน้ารายการสินค้า
│           │   ├── product_detail_page.dart -> หน้าแสดงรายละเอียดสินค้า
│           │   └── search_filter_page.dart -> หน้าค้นหาและกรองสินค้า
│           │
│           └── widgets/
│               ├── product_grid.dart -> แสดงสินค้าในรูปแบบ Grid และปรับจำนวนคอลัมน์ตามขนาดหน้าจอ
│               ├── product_card.dart -> แสดงข้อมูลสินค้าแต่ละชิ้นในรูปแบบ Card
│               ├── category_selector.dart -> แสดงตัวเลือกหมวดหมู่สินค้า
│               ├── loading_widget.dart -> แสดงสถานะ Loading ระหว่างรอข้อมูล
│               ├── error_widget.dart -> แสดงข้อความเมื่อเกิดข้อผิดพลาด พร้อมปุ่ม Retry
│               └── empty_widget.dart -> แสดงข้อความเมื่อไม่มีข้อมูลสินค้าที่ตรงกับเงื่อนไข
│
└── pubspec.yaml