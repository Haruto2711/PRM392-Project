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
    OrigamiModel(
      id: 5,
      title: 'Cáo Giấy Cute',
      category: 'Động vật',
      difficulty: 1,
      stepsCount: 4,
      timeEstimate: '3 phút',
      description: 'Mẫu gấp đầu con cáo siêu dễ thương và cực kỳ nhanh chóng, rất phù hợp cho các bé tập gấp.',
      imagePath: 'assets/images/fox_complete.png',
      steps: [
        'Gấp đôi tờ giấy hình vuông theo đường chéo để tạo hình tam giác.',
        'Gập tiếp đôi hình tam giác rồi mở ra lấy nếp gấp ở giữa.',
        'Gập hai góc nhọn bên hông xuống dưới hướng về góc nhọn đỉnh dưới.',
        'Lật mặt sau, bẻ nhẹ phần tai cáo và phần mũi cáo ra để hoàn thành đầu cáo.',
      ],
      stepImages: [
        'assets/images/fox_step1.png',
        'assets/images/fox_step2.png',
        'assets/images/fox_step3.png',
        'assets/images/fox_step4.png',
      ],
      currentStep: 0,
    ),
    OrigamiModel(
      id: 6,
      title: 'Máy Bay Phản Lực',
      category: 'Đồ vật',
      difficulty: 2,
      stepsCount: 4,
      timeEstimate: '4 phút',
      description: 'Phiên bản máy bay giấy phản lực có cấu trúc khí động học tốt, có thể bay rất xa.',
      imagePath: 'assets/images/jet_complete.png',
      steps: [
        'Gấp đôi tờ giấy A4 theo chiều dọc để lấy nếp gấp ở giữa.',
        'Gấp hai mép góc trên vào giữa tạo thành hình tam giác nhọn đỉnh.',
        'Tiếp tục gấp hai mép bên vào đường giữa để mũi máy bay nhọn hơn.',
        'Gập đôi máy bay dọc theo đường nếp giữa, bẻ ngược hai bên cánh xuống tạo cánh phản lực phẳng.',
      ],
      stepImages: [
        'assets/images/jet_step1.png',
        'assets/images/jet_step2.png',
        'assets/images/jet_step3.png',
        'assets/images/jet_step4.png',
      ],
      currentStep: 0,
    ),
    OrigamiModel(
      id: 7,
      title: 'Hoa Tulip Mùa Xuân',
      category: 'Hoa',
      difficulty: 2,
      stepsCount: 5,
      timeEstimate: '5 phút',
      description: 'Bông hoa tulip mùa xuân nở rộ duyên dáng với các bước gấp đơn giản tạo khối 3D.',
      imagePath: 'assets/images/tulip_complete.png',
      steps: [
        'Gấp đôi tờ giấy hình vuông theo đường chéo tạo thành hình tam giác.',
        'Gập góc dưới bên phải xéo lên trên về phía bên phải của đỉnh.',
        'Gập góc dưới bên trái xéo lên trên về phía bên trái của đỉnh.',
        'Gập nhẹ phần góc đáy nhọn bên dưới ra phía sau để bông hoa đứng vững.',
        'Ghép thêm một tờ giấy màu xanh gấp cuốn làm cành và lá để hoàn chỉnh hoa tulip.',
      ],
      stepImages: [
        'assets/images/tulip_step1.png',
        'assets/images/tulip_step2.png',
        'assets/images/tulip_step3.png',
        'assets/images/tulip_step4.png',
        'assets/images/tulip_step5.png',
      ],
      currentStep: 0,
    ),
    OrigamiModel(
      id: 8,
      title: 'Khủng Long Cổ Dài',
      category: 'Động vật',
      difficulty: 5,
      stepsCount: 6,
      timeEstimate: '20 phút',
      description: 'Thử thách gấp giấy siêu khó mô phỏng loài khủng long ăn cỏ cổ dài khổng lồ Brachiosaurus.',
      imagePath: 'assets/images/brachio_complete.png',
      steps: [
        'Bắt đầu với nếp gấp cơ bản hình vuông (Square Base).',
        'Gấp mép tạo cánh hoa đào (Petal fold) tạo các chi dài giống hạc giấy.',
        'Thực hiện gấp ngược trong (Inside reverse fold) tạo cổ dài hướng lên trên.',
        'Gấp ngược một góc nhỏ ở đỉnh đầu tạo mỏ và đầu khủng long cổ dài.',
        'Bẻ đôi phần thân sau xuống tạo đuôi dài thon gọn.',
        'Tạo các nếp gấp chéo nhỏ ở dưới bụng để định hình 4 chân vững chắc.',
      ],
      stepImages: [
        'assets/images/brachio_step1.png',
        'assets/images/brachio_step2.png',
        'assets/images/brachio_step3.png',
        'assets/images/brachio_step4.png',
        'assets/images/brachio_step5.png',
        'assets/images/brachio_step6.png',
      ],
      currentStep: 0,
    ),
  ];
}
