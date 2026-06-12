import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../mock_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  late Box _usersBox;
  late Box _modelsBox;
  late Box _progressBox;
  late Box _favoritesBox;
  late Box _sessionBox;

  // Khởi tạo Hive boxes và seed dữ liệu nếu rỗng
  Future<void> init() async {
    _usersBox = await Hive.openBox('users');
    _modelsBox = await Hive.openBox('origami_models');
    _progressBox = await Hive.openBox('user_progress');
    _favoritesBox = await Hive.openBox('favorites');
    _sessionBox = await Hive.openBox('session');

    await _seedInitialData();
  }

  Future<void> _seedInitialData() async {
    if (_modelsBox.isEmpty) {
      // Seed 4 mẫu Origami cơ bản
      final initialModels = [
        {
          'id': 1,
          'title': 'Chim Hạc Giấy',
          'difficulty': 2,
          'category': 'Động vật',
          'steps_count': 9,
          'time_estimate': '5 phút',
          'description': 'Mẫu gấp chim hạc giấy truyền thống của Nhật Bản, biểu tượng của sự hòa bình và may mắn.',
          'image_path': 'assets/images/crane_complete.png',
          'steps': [
            'Gấp đôi tờ giấy theo cả hai đường chéo, sau đó mở ra tạo nếp gấp hình chữ X.',
            'Lật tờ giấy, gấp đôi theo chiều ngang và dọc để tạo nếp gấp hình chữ thập (+).',
            'Khéo léo túm bốn góc giấy chụm vào nhau, xẹp xuống thành hình vuông nhỏ (Square Base).',
            'Gập mép hai bên góc mở vào đường giữa tạo thành hình diều (Kite fold).',
            'Gấp góc nhọn đỉnh xuống dưới lấy nếp, mở các mép ra rồi kéo mép dưới lên trên tạo cánh hoa đào (Petal fold).',
            'Lật mặt sau và lặp lại thao tác gấp mép và kéo tạo cánh hoa đào tương tự.',
            'Gấp mép hai cánh bên hông vào đường trục giữa cho hông thon nhỏ lại (ở cả 2 mặt).',
            'Sử dụng đường gấp ngược trong (Inside reverse fold) để bẻ hướng hai chân dưới lên trên làm cổ và đuôi hạc.',
            'Gập ngược đầu cổ xuống làm mỏ hạc, bẻ nhẹ cánh hạc sang hai bên và thổi nhẹ vào đáy hạc để hoàn thành.'
          ],
          'stepImages': [
            'assets/images/crane_step1.png',
            'assets/images/crane_step2.png',
            'assets/images/crane_step3.png',
            'assets/images/crane_step4.png',
            'assets/images/crane_step5.png',
            'assets/images/crane_step6.png',
            'assets/images/crane_step7.png',
            'assets/images/crane_step8.png',
            'assets/images/crane_step9.png',
          ],
        },
        {
          'id': 2,
          'title': 'Thuyền Giấy',
          'difficulty': 1,
          'category': 'Đồ vật',
          'steps_count': 3,
          'time_estimate': '3 phút',
          'description': 'Mẫu gấp thuyền giấy cổ điển cực kỳ đơn giản và quen thuộc với tuổi thơ.',
          'image_path': 'assets/images/boat_complete.png',
          'steps': [
            'Gấp đôi tờ giấy hình chữ nhật theo chiều dọc.',
            'Gập hai góc phía trên vào giữa tạo thành hình tam giác cân, phần giấy thừa phía dưới gập ngược lên hai phía.',
            'Mở rộng lòng hình tam giác thành hình vuông, sau đó kéo hai góc đối diện ra ngoài để tạo hình thuyền.',
          ],
          'stepImages': [
            'assets/images/boat_step1.png',
            'assets/images/boat_step2.png',
            'assets/images/boat_step3.png',
          ],
        },
        {
          'id': 3,
          'title': 'Khủng Long T-Rex',
          'difficulty': 4,
          'category': 'Động vật',
          'steps_count': 6,
          'time_estimate': '15 phút',
          'description': 'Mẫu gấp khủng long bạo chúa T-Rex ấn tượng dành cho những người thích thử thách nâng cao.',
          'image_path': 'assets/images/trex_complete.png',
          'steps': [
            'Tạo nếp gấp chéo và nếp gấp ngang dọc làm cơ sở.',
            'Gấp xéo tạo mỏ neo và phần đầu của khủng long.',
            'Tạo nếp gấp tạo hai chân sau vững chãi.',
            'Gập thu hẹp đuôi và tạo hình gai lưng.',
            'Uốn cong phần cổ và đầu hướng xuống.',
            'Tạo chi tiết 2 chi trước nhỏ và hoàn thiện thế đứng.',
          ],
          'stepImages': [
            'assets/images/trex_step1.png',
            'assets/images/trex_step2.png',
            'assets/images/trex_step3.png',
            'assets/images/trex_step4.png',
            'assets/images/trex_step5.png',
            'assets/images/trex_step6.png',
          ],
        },
        {
          'id': 4,
          'title': 'Hoa Hồng Tình Yêu',
          'difficulty': 3,
          'category': 'Hoa',
          'steps_count': 5,
          'time_estimate': '10 phút',
          'description': 'Mẫu gấp bông hoa hồng nở rộ quyến rũ, thích hợp để làm quà tặng hoặc trang trí.',
          'image_path': 'assets/images/rose_complete.png',
          'steps': [
            'Tạo nếp gấp chia tờ giấy thành lưới 4x4.',
            'Gập các mép giấy vào tâm để tạo khối 3D.',
            'Cuộn xoắn tâm giấy để tạo các lớp cánh hoa đan xen.',
            'Gập các góc ngoài xuống dưới làm đài hoa.',
            'Bẻ cong nhẹ các mép cánh hoa ra ngoài để hoa trông nở tự nhiên.',
          ],
          'stepImages': [
            'assets/images/rose_step1.png',
            'assets/images/rose_step2.png',
            'assets/images/rose_step3.png',
            'assets/images/rose_step4.png',
            'assets/images/rose_step5.png',
          ],
        }
      ];

      for (var model in initialModels) {
        await _modelsBox.put(model['id'], model);
      }
    }
  }

  // --- LOGIC NGHIỆP VỤ HỘ VỆ ---

  // Lấy User hiện tại đang đăng nhập
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _sessionBox.get('currentUser');
    if (user != null) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  // Lưu User đăng nhập hiện tại
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    await _sessionBox.put('currentUser', user);
  }

  // Đăng xuất
  Future<void> logoutUser() async {
    await _sessionBox.delete('currentUser');
  }

  // Đăng ký tài khoản
  Future<int> registerUser(String name, String email, String password) async {
    // Check if user already exists
    if (_usersBox.containsKey(email)) {
      throw Exception('Email đã được đăng ký!');
    }

    // Auto increment logic
    final int nextId = _usersBox.length + 1;
    final user = {
      'id': nextId,
      'name': name,
      'email': email,
      'password': password,
    };
    await _usersBox.put(email, user);
    return nextId;
  }

  // Đăng nhập
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final user = _usersBox.get(email);
    if (user != null) {
      final userMap = Map<String, dynamic>.from(user);
      if (userMap['password'] == password) {
        await setCurrentUser(userMap);
        return userMap;
      }
    }
    return null;
  }

  // Cập nhật họ tên của User
  Future<void> updateUserName(String email, String newName) async {
    final user = _usersBox.get(email);
    if (user != null) {
      final userMap = Map<String, dynamic>.from(user);
      userMap['name'] = newName;
      await _usersBox.put(email, userMap);
      await setCurrentUser(userMap); // Cập nhật session hiện tại luôn
    }
  }

  // Lấy toàn bộ danh sách mẫu Origami
  Future<List<Map<String, dynamic>>> getOrigamiModels() async {
    final List<Map<String, dynamic>> models = [];
    for (var key in _modelsBox.keys) {
      final model = _modelsBox.get(key);
      if (model != null) {
        models.add(Map<String, dynamic>.from(model));
      }
    }
    return models;
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
    final model = _modelsBox.get(modelId);
    if (model == null) return [];

    final modelMap = Map<String, dynamic>.from(model);
    final List<dynamic> stepsList = modelMap['steps'];
    final List<dynamic> stepImagesList = modelMap['stepImages'];
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
    final progressKey = '${userId}_${modelId}';
    final progress = _progressBox.get(progressKey);
    if (progress != null) {
      return Map<String, dynamic>.from(progress);
    }
    return null;
  }

  // Cập nhật hoặc ghi nhận tiến độ mới
  Future<void> updateProgress(int userId, int modelId, int currentStep, int isCompleted) async {
    final progressKey = '${userId}_${modelId}';
    final data = {
      'user_id': userId,
      'model_id': modelId,
      'current_step': currentStep,
      'is_completed': isCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _progressBox.put(progressKey, data);
  }

  // Lấy danh sách mẫu gấp dở để hiện ở Home Dashboard
  Future<List<Map<String, dynamic>>> getIncompleteProgress(int userId) async {
    final List<Map<String, dynamic>> results = [];
    for (var key in _progressBox.keys) {
      if (key.toString().startsWith('${userId}_')) {
        final progress = _progressBox.get(key);
        if (progress != null) {
          final progressMap = Map<String, dynamic>.from(progress);
          if (progressMap['is_completed'] == 0) {
            // Lấy thông tin model tương ứng
            final modelId = progressMap['model_id'];
            final model = _modelsBox.get(modelId);
            if (model != null) {
              final modelMap = Map<String, dynamic>.from(model);
              results.add({
                ...progressMap,
                'title': modelMap['title'],
                'image_path': modelMap['image_path'],
                'steps_count': modelMap['steps_count'],
              });
            }
          }
        }
      }
    }
    return results;
  }

  // Thống kê: Lấy số lượng mẫu đã hoàn thành thành công (Thành quả bản thân)
  Future<int> getCompletedCount(int userId) async {
    int count = 0;
    for (var key in _progressBox.keys) {
      if (key.toString().startsWith('${userId}_')) {
        final progress = _progressBox.get(key);
        if (progress != null) {
          final progressMap = Map<String, dynamic>.from(progress);
          if (progressMap['is_completed'] == 1) {
            count++;
          }
        }
      }
    }
    return count;
  }

  // --- QUẢN LÝ YÊU THÍCH ---

  // Kiểm tra mẫu có yêu thích hay không
  Future<bool> isFavorite(int userId, int modelId) async {
    final favKey = '${userId}_${modelId}';
    return _favoritesBox.get(favKey, defaultValue: false) as bool;
  }

  // Đổi trạng thái yêu thích
  Future<void> toggleFavorite(int userId, int modelId) async {
    final favKey = '${userId}_${modelId}';
    final currentStatus = _favoritesBox.get(favKey, defaultValue: false) as bool;
    await _favoritesBox.put(favKey, !currentStatus);
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
