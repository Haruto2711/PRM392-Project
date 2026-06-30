import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import '../utils/video_helper.dart';


class VideoStepPlayer extends StatefulWidget {
  final String assetPath;
  final bool autoPlay;
  final bool looping;
  final bool startMuted;
  final bool showControls;

  const VideoStepPlayer({
    Key? key,
    required this.assetPath,
    this.autoPlay = true,
    this.looping = true,
    this.startMuted = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  _VideoStepPlayerState createState() => _VideoStepPlayerState();
}

class _VideoStepPlayerState extends State<VideoStepPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  double _currentSpeed = 1.0;
  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _isDragging = false;
  double? _dragValue;
  bool _isCopying = false; // Trạng thái sao chép file asset sang file cục bộ

  @override
  void initState() {
    super.initState();
    _isMuted = widget.startMuted;
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoStepPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _controller.dispose();
      _hideTimer?.cancel();
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _controlsVisible = true;
        _currentSpeed = 1.0;
        _isCopying = false;
      });
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    try {
      if (widget.assetPath.startsWith('http://') || widget.assetPath.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.assetPath));
      } else {
        setState(() {
          _isCopying = true;
        });
        
        // Sử dụng VideoHelper để tự động copy-cache (Native) hoặc tạo Blob URL (Web)
        final String videoUrl = await VideoHelper.getVideoUrl(widget.assetPath);
        
        if (kIsWeb) {
          _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        } else {
          _controller = VideoPlayerController.file(File(videoUrl));
        }
      }
      
      await _controller.initialize();
      _controller.setLooping(widget.looping);
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
      _controller.setPlaybackSpeed(_currentSpeed);
      
      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      if (widget.autoPlay) {
        await _controller.play();
        _resetHideTimer();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isCopying = false;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isCopying = false;
        });
      }
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (_controller.value.isPlaying && widget.showControls) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  void _toggleControlsVisibility() {
    if (!widget.showControls) return;
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _resetHideTimer();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _resetHideTimer();
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _resetHideTimer();
      }
    });
  }

  void _toggleMute() {
    _resetHideTimer();
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  Future<void> _performSeek(Duration newPosition) async {
    if (!_controller.value.isInitialized) return;
    _resetHideTimer();
    
    // Tạm dừng video để tránh xung đột luồng giải mã khi seek trên một số thiết bị
    final bool wasPlaying = _controller.value.isPlaying;
    if (wasPlaying) {
      await _controller.pause();
    }
    
    await _controller.seekTo(newPosition);
    
    // Đợi một khoảng ngắn (300ms) để đầu phát native cập nhật vị trí đệm mới
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Tiếp tục phát lại sau khi seek hoàn tất
    if (wasPlaying && mounted) {
      await _controller.play();
    }
  }

  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _performSeek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _seekForward() {
    final currentPosition = _controller.value.position;
    final totalDuration = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _performSeek(newPosition > totalDuration ? totalDuration : newPosition);
  }

  void _cycleSpeed() {
    _resetHideTimer();
    final currentIndex = _speeds.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % _speeds.length;
    setState(() {
      _currentSpeed = _speeds[nextIndex];
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  Future<void> _toggleFullscreen() async {
    _resetHideTimer();
    
    final wasPlaying = _controller.value.isPlaying;
    
    // Set landscape orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenVideoPlayer(
            controller: _controller,
            onClose: () async {
              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: SystemUiOverlay.values,
              );
            },
          ),
        ),
      );
    }

    // Reset preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    if (wasPlaying && !_controller.value.isPlaying) {
      _controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "$minutes:${twoDigits(seconds)}";
  }

  Widget _buildProgressBar() {
    if (!_controller.value.isInitialized) return const SizedBox(height: 24);

    final double totalMs = _controller.value.duration.inMilliseconds.toDouble();
    final double currentMs = _controller.value.position.inMilliseconds.toDouble();
    
    // Nếu đang kéo (drag), sử dụng giá trị kéo, ngược lại dùng vị trí phát thực tế
    final double sliderValue = _isDragging 
        ? (_dragValue ?? currentMs) 
        : currentMs;

    return Container(
      height: 24, // Vùng chạm rộng rãi 24px để dễ nhấn trúng ngón tay
      alignment: Alignment.center,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4, // Sleek 4px track
          activeTrackColor: Colors.redAccent, // YouTube red played color
          inactiveTrackColor: Colors.white24, // Muted gray unplayed color
          thumbColor: Colors.redAccent, // YouTube red thumb color
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), // 12px circular playhead
          overlayColor: Colors.red.withOpacity(0.24),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          trackShape: const RectangularSliderTrackShape(), // Bỏ lề thụt lùi 2 đầu
        ),
        child: Slider(
          value: sliderValue.clamp(0.0, totalMs > 0 ? totalMs : 1.0),
          min: 0.0,
          max: totalMs > 0 ? totalMs : 1.0,
          onChangeStart: (value) {
            setState(() {
              _isDragging = true;
              _dragValue = value;
            });
          },
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
            // KHÔNG gọi seekTo ở đây để tránh spam lệnh làm nghẽn luồng phát của video player
          },
          onChangeEnd: (value) async {
            setState(() {
              _dragValue = value;
            });
            // Thực hiện seek bất đồng bộ an toàn qua helper và đợi đến khi hoàn tất
            await _performSeek(Duration(milliseconds: value.toInt()));
            if (mounted) {
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 8),
              Text(
                'Không thể phát video này.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCopying) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
            SizedBox(height: 12),
            Text(
              'Đang chuẩn bị video hướng dẫn...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
      );
    }

    final durationText = "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}";

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Trình phát video chính
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),

        // 2. Lớp cảm ứng phát/tạm dừng và hiện controls khi tap vào video
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleControlsVisibility,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),

        // 3. Lớp phủ điều khiển kiểu YouTube (Tự động ẩn hiện)
        if (widget.showControls)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black38, // Nền mờ giúp các nút hiển thị rõ ràng hơn
                  child: Stack(
                    children: [
                      // Bộ nút tua nhanh/chậm và Play/Pause ở chính giữa
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Nút tua lại 10 giây
                            IconButton(
                              icon: const Icon(Icons.replay_10, size: 36, color: Colors.white),
                              onPressed: _seekBackward,
                            ),
                            // Nút Play/Pause chính giữa lớn
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 56,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlay,
                            ),
                            // Nút tua đi 10 giây
                            IconButton(
                              icon: const Icon(Icons.forward_10, size: 36, color: Colors.white),
                              onPressed: _seekForward,
                            ),
                          ],
                        ),
                      ),

                      // Bảng điều khiển đáy (Thanh trượt, thời gian, tốc độ, volume)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withOpacity(0.64)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Thanh trượt tua video tự vẽ kiểu YouTube hỗ trợ chạm bất kỳ điểm nào để tua
                              _buildProgressBar(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Hiển thị thời gian dạng 0:22 / 2:48
                                  Text(
                                    durationText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Nút điều chỉnh tốc độ (Speed selector)
                                      GestureDetector(
                                        onTap: _cycleSpeed,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "${_currentSpeed}x",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Nút Mute/Unmute
                                      GestureDetector(
                                        onTap: _toggleMute,
                                        child: Icon(
                                          _isMuted ? Icons.volume_off : Icons.volume_up,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Nút Fullscreen
                                      GestureDetector(
                                        onTap: _toggleFullscreen,
                                        child: const Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClose;

  const FullscreenVideoPlayer({
    Key? key,
    required this.controller,
    required this.onClose,
  }) : super(key: key);

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _controlsVisible = true;
  Timer? _hideTimer;
  bool _isDragging = false;
  double? _dragValue;
  double _currentSpeed = 1.0;
  bool _isMuted = false;
  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.controller.value.playbackSpeed;
    _isMuted = widget.controller.value.volume == 0.0;
    widget.controller.addListener(_onControllerUpdate);
    _startHideTimer();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _resetHideTimer() {
    if (mounted) {
      setState(() {
        _controlsVisible = true;
      });
      _startHideTimer();
    }
  }

  void _togglePlay() {
    _resetHideTimer();
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _seekForward() {
    _resetHideTimer();
    final currentPosition = widget.controller.value.position;
    final totalDuration = widget.controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    widget.controller.seekTo(newPosition > totalDuration ? totalDuration : newPosition);
  }

  void _seekBackward() {
    _resetHideTimer();
    final currentPosition = widget.controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    widget.controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _toggleMute() {
    _resetHideTimer();
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _cycleSpeed() {
    _resetHideTimer();
    final currentIndex = _speeds.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % _speeds.length;
    setState(() {
      _currentSpeed = _speeds[nextIndex];
      widget.controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "$minutes:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    final durationText = "${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Fullscreen video player
          GestureDetector(
            onTap: () {
              if (_controlsVisible) {
                setState(() {
                  _controlsVisible = false;
                });
              } else {
                _resetHideTimer();
              }
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
          ),

          // 2. Play/Pause overlay
          IgnorePointer(
            ignoring: !_controlsVisible,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black26,
                child: Stack(
                  children: [
                    // Center controls
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, size: 48, color: Colors.white),
                            onPressed: _seekBackward,
                          ),
                          IconButton(
                            icon: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 72,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlay,
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_10, size: 48, color: Colors.white),
                            onPressed: _seekForward,
                          ),
                        ],
                      ),
                    ),

                    // Exit fullscreen button (top-right)
                    Positioned(
                      top: 24,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit, size: 36, color: Colors.white),
                        onPressed: () {
                          widget.onClose();
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // Bottom controls (progress bar, time, speed, volume)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar
                            _buildProgressBar(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  durationText,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _cycleSpeed,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "${_currentSpeed}x",
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: _toggleMute,
                                      child: Icon(
                                        _isMuted ? Icons.volume_off : Icons.volume_up,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onClose();
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.fullscreen_exit,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (!widget.controller.value.isInitialized) return const SizedBox(height: 24);

    final double totalMs = widget.controller.value.duration.inMilliseconds.toDouble();
    final double currentMs = widget.controller.value.position.inMilliseconds.toDouble();
    final double sliderValue = _isDragging ? (_dragValue ?? currentMs) : currentMs;

    return Container(
      height: 24,
      alignment: Alignment.center,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: Colors.redAccent,
          inactiveTrackColor: Colors.white24,
          thumbColor: Colors.redAccent,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayColor: Colors.red.withOpacity(0.24),
          trackShape: const RectangularSliderTrackShape(),
        ),
        child: Slider(
          value: sliderValue.clamp(0.0, totalMs > 0 ? totalMs : 1.0),
          min: 0.0,
          max: totalMs > 0 ? totalMs : 1.0,
          onChangeStart: (value) {
            setState(() {
              _isDragging = true;
              _dragValue = value;
            });
          },
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
          },
          onChangeEnd: (value) async {
            setState(() {
              _dragValue = value;
            });
            await widget.controller.seekTo(Duration(milliseconds: value.toInt()));
            if (mounted) {
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            }
          },
        ),
      ),
    );
  }
}
