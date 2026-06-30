import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../mock_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('origami_master.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE origami_models (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        steps_count INTEGER NOT NULL,
        time_estimate TEXT NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT NOT NULL,
        steps TEXT NOT NULL,
        stepImages TEXT NOT NULL,
        stepDiagrams TEXT NOT NULL,
        videoTutorial TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        user_id INTEGER NOT NULL,
        model_id INTEGER NOT NULL,
        current_step INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (user_id, model_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        user_id INTEGER NOT NULL,
        model_id INTEGER NOT NULL,
        PRIMARY KEY (user_id, model_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE session (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // Khởi tạo SQLite DB và seed dữ liệu nếu rỗng
  Future<void> init() async {
    final db = await database;
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM origami_models'),
    );

    // Nếu số lượng mẫu trong CSDL khác số lượng mẫu trong MockData, xóa đi và seed lại
    if (countResult != MockData.models.length) {
      await db.delete('origami_models');
      for (var model in MockData.models) {
        await db.insert('origami_models', {
          'id': model.id,
          'title': model.title,
          'category': model.category,
          'difficulty': model.difficulty,
          'steps_count': model.stepsCount,
          'time_estimate': model.timeEstimate,
          'description': model.description,
          'image_path': model.imagePath,
          'steps': jsonEncode(model.steps),
          'stepImages': jsonEncode(model.stepImages),
          'stepDiagrams': jsonEncode(model.stepDiagrams),
          'videoTutorial': model.videoTutorial,
        });
      }
    }

    // Tự động thêm tài khoản mặc định để kiểm thử không bao giờ lo bị mất
    final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE email = ?', ['user@gmail.com']),
    );
    if (userCount == 0) {
      await db.insert('users', {
        'name': 'Origami Master',
        'email': 'user@gmail.com',
        'password': 'password123',
      });
    }
  }

  // --- LOGIC NGHIỆP VỤ HỘ VỆ ---

  // Lấy User hiện tại đang đăng nhập
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'session',
      where: 'key = ?',
      whereArgs: ['currentUser'],
    );
    if (maps.isNotEmpty) {
      return jsonDecode(maps.first['value'] as String) as Map<String, dynamic>;
    }
    return null;
  }

  // Lưu User đăng nhập hiện tại
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'session',
      {
        'key': 'currentUser',
        'value': jsonEncode(user),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Đăng xuất
  Future<void> logoutUser() async {
    final db = await database;
    await db.delete(
      'session',
      where: 'key = ?',
      whereArgs: ['currentUser'],
    );
  }

  // Đăng ký tài khoản
  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    // Check if user already exists
    final List<Map<String, dynamic>> existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existing.isNotEmpty) {
      throw Exception('Email đã được đăng ký!');
    }

    final id = await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
    return id;
  }

  // Đăng nhập
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      final userMap = Map<String, dynamic>.from(maps.first);
      await setCurrentUser(userMap);
      return userMap;
    }
    return null;
  }

  // Cập nhật họ tên của User
  Future<void> updateUserName(String email, String newName) async {
    final db = await database;
    await db.update(
      'users',
      {'name': newName},
      where: 'email = ?',
      whereArgs: [email],
    );
    final currentUser = await getCurrentUser();
    if (currentUser != null && currentUser['email'] == email) {
      currentUser['name'] = newName;
      await setCurrentUser(currentUser);
    }
  }

  // Cập nhật ảnh đại diện của User
  Future<void> updateUserAvatar(String email, String base64Image) async {
    final db = await database;
    await db.update(
      'users',
      {'avatar': base64Image},
      where: 'email = ?',
      whereArgs: [email],
    );
    final currentUser = await getCurrentUser();
    if (currentUser != null && currentUser['email'] == email) {
      currentUser['avatar'] = base64Image;
      await setCurrentUser(currentUser);
    }
  }

  // Lấy toàn bộ danh sách mẫu Origami
  Future<List<Map<String, dynamic>>> getOrigamiModels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('origami_models');
    return maps.map((m) {
      final map = Map<String, dynamic>.from(m);
      map['steps'] = jsonDecode(map['steps'] as String);
      map['stepImages'] = jsonDecode(map['stepImages'] as String);
      map['stepDiagrams'] = jsonDecode(map['stepDiagrams'] as String);
      return map;
    }).toList();
  }

  // Lấy danh sách OrigamiModel ánh xạ dữ liệu tiến độ và yêu thích cho User cụ thể
  Future<List<OrigamiModel>> getOrigamiModelsForUser(int userId) async {
    final dbModels = await getOrigamiModels();
    final List<OrigamiModel> result = [];
    for (var m in dbModels) {
      final modelId = m['id'] as int;
      final fav = await isFavorite(userId, modelId);
      final prog = await getProgress(userId, modelId);
      final currentStep = prog != null ? prog['current_step'] as int : 0;
      final isCompleted = prog != null ? (prog['is_completed'] as int) == 1 : false;

      result.add(OrigamiModel(
        id: modelId,
        title: m['title'] as String,
        category: m['category'] as String,
        difficulty: m['difficulty'] as int,
        stepsCount: m['steps_count'] as int,
        timeEstimate: m['time_estimate'] as String,
        description: m['description'] as String,
        imagePath: m['image_path'] as String,
        steps: List<String>.from(m['steps'] ?? []),
        stepImages: List<String>.from(m['stepImages'] ?? []),
        stepDiagrams: List<String>.from(m['stepDiagrams'] ?? []),
        videoTutorial: m['videoTutorial'] as String?,
        isFavorite: fav,
        currentStep: currentStep,
        isCompleted: isCompleted,
      ));
    }
    // Sắp xếp theo ID cho đồng nhất
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  // Lấy danh sách các bước gấp của một mẫu cụ thể
  Future<List<Map<String, dynamic>>> getStepsForModel(int modelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [modelId],
    );
    if (maps.isEmpty) return [];

    final modelMap = maps.first;
    final List<dynamic> stepsList = jsonDecode(modelMap['steps'] as String);
    final List<dynamic> stepImagesList = jsonDecode(modelMap['stepImages'] as String);
    final List<Map<String, dynamic>> stepsResult = [];

    for (int i = 0; i < stepsList.length; i++) {
      stepsResult.add({
        'id': i + 1,
        'model_id': modelId,
        'step_number': i + 1,
        'instruction': stepsList[i],
        'image_path': stepImagesList[i],
      });
    }
    return stepsResult;
  }

  // --- QUẢN LÝ TIẾN ĐỘ ---

  // Lấy tiến độ gấp dở
  Future<Map<String, dynamic>?> getProgress(int userId, int modelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'user_id = ? AND model_id = ?',
      whereArgs: [userId, modelId],
    );
    if (maps.isNotEmpty) {
      return Map<String, dynamic>.from(maps.first);
    }
    return null;
  }

  // Cập nhật hoặc ghi nhận tiến độ mới
  Future<void> updateProgress(int userId, int modelId, int currentStep, int isCompleted) async {
    final db = await database;
    await db.insert(
      'user_progress',
      {
        'user_id': userId,
        'model_id': modelId,
        'current_step': currentStep,
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy danh sách mẫu gấp dở để hiện ở Home Dashboard
  Future<List<Map<String, dynamic>>> getIncompleteProgress(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'user_id = ? AND is_completed = 0',
      whereArgs: [userId],
    );
    final List<Map<String, dynamic>> results = [];
    for (var progressMap in maps) {
      final modelId = progressMap['model_id'] as int;
      final List<Map<String, dynamic>> modelMaps = await db.query(
        'origami_models',
        where: 'id = ?',
        whereArgs: [modelId],
      );
      if (modelMaps.isNotEmpty) {
        final modelMap = modelMaps.first;
        results.add({
          ...progressMap,
          'title': modelMap['title'],
          'image_path': modelMap['image_path'],
          'steps_count': modelMap['steps_count'],
        });
      }
    }
    return results;
  }

  // Thống kê: Lấy số lượng mẫu đã hoàn thành thành công (Thành quả bản thân)
  Future<int> getCompletedCount(int userId) async {
    final db = await database;
    final countResult = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM user_progress WHERE user_id = ? AND is_completed = 1',
      [userId],
    ));
    return countResult ?? 0;
  }

  // --- QUẢN LÝ YÊU THÍCH ---

  // Kiểm tra mẫu có yêu thích hay không
  Future<bool> isFavorite(int userId, int modelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'user_id = ? AND model_id = ?',
      whereArgs: [userId, modelId],
    );
    return maps.isNotEmpty;
  }

  // Đổi trạng thái yêu thích
  Future<void> toggleFavorite(int userId, int modelId) async {
    final db = await database;
    final bool exists = await isFavorite(userId, modelId);
    if (exists) {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND model_id = ?',
        whereArgs: [userId, modelId],
      );
    } else {
      await db.insert('favorites', {
        'user_id': userId,
        'model_id': modelId,
      });
    }
  }

  // Lấy danh sách các mẫu đã yêu thích
  Future<List<Map<String, dynamic>>> getFavoriteModels(int userId) async {
    final List<Map<String, dynamic>> results = [];
    final allModels = await getOrigamiModels();
    for (var model in allModels) {
      final modelId = model['id'] as int;
      if (await isFavorite(userId, modelId)) {
        results.add(model);
      }
    }
    return results;
  }
}
