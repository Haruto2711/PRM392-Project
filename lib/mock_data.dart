class OrigamiModel {
  final int id;
  final String title;
  final String category;
  final int difficulty; // 1-5
  final int stepsCount;
  final String timeEstimate;
  final String description;
  final String imagePath;
  final List<String> steps;
  final List<String> stepImages;
  bool isFavorite;
  int currentStep; // 0 nếu chưa gấp, > 0 biểu thị bước đang gấp dở
  bool isCompleted;

  OrigamiModel({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.stepsCount,
    required this.timeEstimate,
    required this.description,
    required this.imagePath,
    required this.steps,
    required this.stepImages,
    this.isFavorite = false,
    this.currentStep = 0,
    this.isCompleted = false,
  });
}

class MockData {
  static List<OrigamiModel> models = [
    OrigamiModel(
      id: 1,
      title: 'Chim Hạc Giấy',
      category: 'Động vật',
      difficulty: 2,
      stepsCount: 9,
      timeEstimate: '5 phút',
      description: 'Mẫu gấp chim hạc giấy truyền thống của Nhật Bản, biểu tượng của sự hòa bình và may mắn.',
      imagePath: 'assets/images/crane_complete.png',
      steps: [
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
      stepImages: [
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
      currentStep: 2, // Đang gấp dở bước 2
    ),
    OrigamiModel(
      id: 2,
      title: 'Thuyền Giấy',
      category: 'Đồ vật',
      difficulty: 1,
      stepsCount: 3,
      timeEstimate: '3 phút',
      description: 'Mẫu gấp thuyền giấy cổ điển cực kỳ đơn giản và quen thuộc với tuổi thơ.',
      imagePath: 'assets/images/boat_complete.png',
      steps: [
        'Gấp đôi tờ giấy hình chữ nhật theo chiều dọc.',
        'Gập hai góc phía trên vào giữa tạo thành hình tam giác cân, phần giấy thừa phía dưới gập ngược lên hai phía.',
        'Mở rộng lòng hình tam giác thành hình vuông, sau đó kéo hai góc đối diện ra ngoài để tạo hình thuyền.',
      ],
      stepImages: [
        'assets/images/boat_step1.png',
        'assets/images/boat_step2.png',
        'assets/images/boat_step3.png',
      ],
      isFavorite: true,
      currentStep: 0,
    ),
    OrigamiModel(
      id: 3,
      title: 'Khủng Long T-Rex',
      category: 'Động vật',
      difficulty: 4,
      stepsCount: 6,
      timeEstimate: '15 phút',
      description: 'Mẫu gấp khủng long bạo chúa T-Rex ấn tượng dành cho những người thích thử thách nâng cao.',
      imagePath: 'assets/images/trex_complete.png',
      steps: [
        'Tạo nếp gấp chéo và nếp gấp ngang dọc làm cơ sở.',
        'Gấp xéo tạo mỏ neo và phần đầu của khủng long.',
        'Tạo nếp gấp tạo hai chân sau vững chãi.',
        'Gập thu hẹp đuôi và tạo hình gai lưng.',
        'Uốn cong phần cổ và đầu hướng xuống.',
        'Tạo chi tiết 2 chi trước nhỏ và hoàn thiện thế đứng.',
      ],
      stepImages: [
        'assets/images/trex_step1.png',
        'assets/images/trex_step2.png',
        'assets/images/trex_step3.png',
        'assets/images/trex_step4.png',
        'assets/images/trex_step5.png',
        'assets/images/trex_step6.png',
      ],
      currentStep: 0,
    ),
    OrigamiModel(
      id: 4,
      title: 'Hoa Hồng Tình Yêu',
      category: 'Hoa',
      difficulty: 3,
      stepsCount: 5,
      timeEstimate: '10 phút',
      description: 'Mẫu gấp bông hoa hồng nở rộ quyến rũ, thích hợp để làm quà tặng hoặc trang trí.',
      imagePath: 'assets/images/rose_complete.png',
      steps: [
        'Tạo nếp gấp chia tờ giấy thành lưới 4x4.',
        'Gập các mép giấy vào tâm để tạo khối 3D.',
        'Cuộn xoắn tâm giấy để tạo các lớp cánh hoa đan xen.',
        'Gập các góc ngoài xuống dưới làm đài hoa.',
        'Bẻ cong nhẹ các mép cánh hoa ra ngoài để hoa trông nở tự nhiên.',
      ],
      stepImages: [
        'assets/images/rose_step1.png',
        'assets/images/rose_step2.png',
        'assets/images/rose_step3.png',
        'assets/images/rose_step4.png',
        'assets/images/rose_step5.png',
      ],
      isFavorite: true,
      currentStep: 3, // Đang gấp dở bước 3
    ),
  ];
}
