import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('origami.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType UNIQUE,
        password $textType
      )
    ''');

    // Origami Models Table
    await db.execute('''
      CREATE TABLE origami_models (
        id $idType,
        title $textType,
        difficulty $integerType,
        category $textType,
        steps_count $integerType,
        time_estimate $textType,
        description $textType,
        image_path $textType
      )
    ''');

    // Folding Steps Table
    await db.execute('''
      CREATE TABLE folding_steps (
        id $idType,
        model_id $integerType,
        step_number $integerType,
        instruction $textType,
        image_path $textType,
        FOREIGN KEY (model_id) REFERENCES origami_models (id) ON DELETE CASCADE
      )
    ''');

    // User Progress & Achievements Table
    await db.execute('''
      CREATE TABLE user_progress (
        id $idType,
        user_id $integerType,
        model_id $integerType,
        current_step $integerType,
        is_completed $integerType,
        updated_at $textType,
        FOREIGN KEY (model_id) REFERENCES origami_models (id) ON DELETE CASCADE
      )
    ''');

    // Seed/Insert Initial Origami Models and Steps
    await _seedInitialData(db);
  }

  Future _seedInitialData(Database db) async {
    // 1. Insert Initial Models
    // Chim Hạc Giấy (ID: 1)
    await db.rawInsert('''
      INSERT INTO origami_models (id, title, difficulty, category, steps_count, time_estimate, description, image_path)
      VALUES (1, 'Chim Hạc Giấy', 2, 'Động vật', 9, '5 phút', 'Mẫu gấp chim hạc giấy truyền thống của Nhật Bản, biểu tượng của sự hòa bình và may mắn.', 'assets/images/crane_complete.png')
    ''');

    // Thuyền Giấy (ID: 2)
    await db.rawInsert('''
      INSERT INTO origami_models (id, title, difficulty, category, steps_count, time_estimate, description, image_path)
      VALUES (2, 'Thuyền Giấy', 1, 'Đồ vật', 3, '3 phút', 'Mẫu gấp thuyền giấy cổ điển cực kỳ đơn giản và quen thuộc với tuổi thơ.', 'assets/images/boat_complete.png')
    ''');

    // Khủng Long T-Rex (ID: 3)
    await db.rawInsert('''
      INSERT INTO origami_models (id, title, difficulty, category, steps_count, time_estimate, description, image_path)
      VALUES (3, 'Khủng Long T-Rex', 4, 'Động vật', 6, '15 phút', 'Mẫu gấp khủng long bạo chúa T-Rex ấn tượng dành cho những người thích thử thách nâng cao.', 'assets/images/trex_complete.png')
    ''');

    // Hoa Hồng Tình Yêu (ID: 4)
    await db.rawInsert('''
      INSERT INTO origami_models (id, title, difficulty, category, steps_count, time_estimate, description, image_path)
      VALUES (4, 'Hoa Hồng Tình Yêu', 3, 'Hoa', 5, '10 phút', 'Mẫu gấp bông hoa hồng nở rộ quyến rũ, thích hợp để làm quà tặng hoặc trang trí.', 'assets/images/rose_complete.png')
    ''');

    // 2. Insert Steps for Chim Hạc Giấy (Model ID: 1)
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 1, 'Gấp đôi tờ giấy theo cả hai đường chéo, sau đó mở ra tạo nếp gấp hình chữ X.', 'assets/images/crane_step1.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 2, 'Lật tờ giấy, gấp đôi theo chiều ngang và dọc để tạo nếp gấp hình chữ thập (+).', 'assets/images/crane_step2.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 3, 'Khéo léo túm đóng bốn góc giấy chụm vào nhau, xẹp xuống thành hình vuông nhỏ (Square Base).', 'assets/images/crane_step3.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 4, 'Gập mép hai bên góc mở vào đường giữa tạo thành hình diều (Kite fold).', 'assets/images/crane_step4.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 5, 'Gấp góc nhọn đỉnh xuống dưới lấy nếp, mở các mép ra rồi kéo mép dưới lên trên tạo cánh hoa đào (Petal fold).', 'assets/images/crane_step5.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 6, 'Lật mặt sau và lặp lại thao tác gấp mép và kéo tạo cánh hoa đào tương tự.', 'assets/images/crane_step6.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 7, 'Gấp mép hai cánh bên hông vào đường trục giữa cho hông thon nhỏ lại (ở cả 2 mặt).', 'assets/images/crane_step7.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 8, 'Sử dụng đường gấp ngược trong (Inside reverse fold) để bẻ hướng hai chân dưới lên trên làm cổ và đuôi hạc.', 'assets/images/crane_step8.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (1, 9, 'Gập ngược đầu cổ xuống làm mỏ hạc, bẻ nhẹ cánh hạc sang hai bên và thổi nhẹ vào đáy hạc để hoàn thành.', 'assets/images/crane_step9.png')
    ''');

    // 3. Insert Steps for Thuyền Giấy (Model ID: 2)
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (2, 1, 'Gấp đôi tờ giấy hình chữ nhật theo chiều dọc.', 'assets/images/boat_step1.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (2, 2, 'Gập hai góc phía trên vào giữa tạo thành hình tam giác cân, phần giấy thừa phía dưới gập ngược lên hai phía.', 'assets/images/boat_step2.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (2, 3, 'Mở rộng lòng hình tam giác thành hình vuông, sau đó kéo hai góc đối diện ra ngoài để tạo hình thuyền.', 'assets/images/boat_step3.png')
    ''');

    // 4. Insert Steps for Khủng Long T-Rex (Model ID: 3)
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 1, 'Tạo nếp gấp chéo và nếp gấp ngang dọc làm cơ sở.', 'assets/images/trex_step1.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 2, 'Gấp xéo tạo mỏ neo và phần đầu của khủng long.', 'assets/images/trex_step2.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 3, 'Tạo nếp gấp tạo hai chân sau vững chãi.', 'assets/images/trex_step3.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 4, 'Gập thu hẹp đuôi và tạo hình gai lưng.', 'assets/images/trex_step4.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 5, 'Uốn cong phần cổ và đầu hướng xuống.', 'assets/images/trex_step5.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (3, 6, 'Tạo chi tiết 2 chi trước nhỏ và hoàn thiện thế đứng.', 'assets/images/trex_step6.png')
    ''');

    // 5. Insert Steps for Hoa Hồng Tình Yêu (Model ID: 4)
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (4, 1, 'Tạo nếp gấp chia tờ giấy thành lưới 4x4.', 'assets/images/rose_step1.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (4, 2, 'Gập các mép giấy vào tâm để tạo khối 3D.', 'assets/images/rose_step2.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (4, 3, 'Cuộn xoắn tâm giấy để tạo các lớp cánh hoa đan xen.', 'assets/images/rose_step3.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (4, 4, 'Gập các góc ngoài xuống dưới làm đài hoa.', 'assets/images/rose_step4.png')
    ''');
    await db.rawInsert('''
      INSERT INTO folding_steps (model_id, step_number, instruction, image_path)
      VALUES (4, 5, 'Bẻ cong nhẹ các mép cánh hoa ra ngoài để hoa trông nở tự nhiên.', 'assets/images/rose_step5.png')
    ''');
  }

  // --- LOGIC NGHIỆP VỤ ---

  // Đăng ký tài khoản
  Future<int> registerUser(String name, String email, String password) async {
    final db = await instance.database;
    final user = {
      'name': name,
      'email': email,
      'password': password,
    };
    return await db.insert('users', user);
  }

  // Đăng nhập
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Lấy toàn bộ danh sách mẫu Origami
  Future<List<Map<String, dynamic>>> getOrigamiModels() async {
    final db = await instance.database;
    return await db.query('origami_models');
  }

  // Lấy danh sách các bước gấp của một mẫu cụ thể
  Future<List<Map<String, dynamic>>> getStepsForModel(int modelId) async {
    final db = await instance.database;
    return await db.query(
      'folding_steps',
      where: 'model_id = ?',
      whereArgs: [modelId],
      orderBy: 'step_number ASC',
    );
  }

  // Lấy tiến độ gấp dở
  Future<Map<String, dynamic>?> getProgress(int userId, int modelId) async {
    final db = await instance.database;
    final result = await db.query(
      'user_progress',
      where: 'user_id = ? AND model_id = ?',
      whereArgs: [userId, modelId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Cập nhật hoặc ghi nhận tiến độ mới
  Future<void> updateProgress(int userId, int modelId, int currentStep, int isCompleted) async {
    final db = await instance.database;
    final existing = await getProgress(userId, modelId);
    final data = {
      'user_id': userId,
      'model_id': modelId,
      'current_step': currentStep,
      'is_completed': isCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing == null) {
      await db.insert('user_progress', data);
    } else {
      await db.update(
        'user_progress',
        data,
        where: 'user_id = ? AND model_id = ?',
        whereArgs: [userId, modelId],
      );
    }
  }

  // Lấy danh sách mẫu gấp dở để hiện ở Home Dashboard
  Future<List<Map<String, dynamic>>> getIncompleteProgress(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT p.*, m.title, m.image_path, m.steps_count
      FROM user_progress p
      JOIN origami_models m ON p.model_id = m.id
      WHERE p.user_id = ? AND p.is_completed = 0
    ''', [userId]);
  }

  // Thống kê: Lấy số lượng mẫu đã hoàn thành thành công (Thành quả bản thân)
  Future<int> getCompletedCount(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM user_progress
      WHERE user_id = ? AND is_completed = 1
    ''', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
