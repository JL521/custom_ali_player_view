import 'dart:async';
import 'package:custom_ali_player_view/src/ali_player_manager.dart';
import 'package:custom_ali_player_view/src/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//阿里视频播放器
class ASRAliPlayerView extends StatefulWidget {
  final double width;
  final double height;
  final String url;
  final bool autoPlay;
  const ASRAliPlayerView(this.url, this.width, this.height,
      {Key key, this.autoPlay = true})
      : super(key: key);
  @override
  _ASRAliPlayerViewState createState() {
    // TODO: implement createState
    return _ASRAliPlayerViewState();
  }
}

class _ASRAliPlayerViewState extends State<ASRAliPlayerView> {
  ASRAliPlayer aliPlayer = ASRAliPlayer();
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    aliPlayer.setPlayer(widget.url, autoPlay: widget.autoPlay);
  }

  @override
  void dispose() {
    super.dispose();
    aliPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isFullScreen
        ? Container(width: widget.width, height: widget.height)
        : _AliPlayerViewProvider(
            aliPlayer: aliPlayer,
            child: AliPlayerViewWithControls(
              pushFullScreenFunction: () {
                _pushFullScreenWidget(context);
                setState(() {
                  isFullScreen = true;
                });
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);
              },
              width: widget.width,
              height: widget.height,
              aliPlayer: aliPlayer,
            ));
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute<void> route = PageRouteBuilder<void>(
      pageBuilder: _fullScreenRoutePageBuilder,
      transitionDuration: Duration(milliseconds: 0),
      reverseTransitionDuration: Duration(milliseconds: 0),
    );
    await Navigator.of(context, rootNavigator: true).push(route).then((value) {
      setState(() {
        isFullScreen = false;
      });
    });
  }

  Widget _fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final controllerProvider = _AliPlayerViewProvider(
        aliPlayer: aliPlayer,
        child: AliPlayerViewWithControls(
          isFullScreen: true,
          width: 1.sw,
          height: 1.sh,
          aliPlayer: aliPlayer,
          popFullScreenFunction: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.of(context, rootNavigator: true).pop();
          },
        ));

    return _defaultRoutePageBuilder(
        context, animation, secondaryAnimation, controllerProvider);
  }

  AnimatedWidget _defaultRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    _AliPlayerViewProvider controllerProvider,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return _buildFullScreenVideo(context, animation, controllerProvider);
      },
    );
  }

  Widget _buildFullScreenVideo(
    BuildContext context,
    Animation<double> animation,
    _AliPlayerViewProvider controllerProvider,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: controllerProvider,
        ),
      ),
    );
  }
}

//阿里视频播放视图和控制菜单
class AliPlayerViewWithControls extends StatefulWidget {
  final double width;
  final double height;
  final ASRAliPlayer aliPlayer;
  final pushFullScreenFunction;
  final popFullScreenFunction;
  final bool isFullScreen;
  const AliPlayerViewWithControls(
      {Key key,
      this.width,
      this.height,
      this.aliPlayer,
      this.pushFullScreenFunction,
      this.popFullScreenFunction,
      this.isFullScreen = false})
      : super(key: key);

  @override
  _AliPlayerViewWithControlsState createState() {
    // TODO: implement createState
    return _AliPlayerViewWithControlsState();
  }
}

class _AliPlayerViewWithControlsState extends State<AliPlayerViewWithControls> {
  @override
  void initState() {
    super.initState();
    widget.aliPlayer.playerValue.addListener(listener);
  }

  void listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.aliPlayer.playerValue.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    ASRAliPlayer aliPlayer = context
        .dependOnInheritedWidgetOfExactType<_AliPlayerViewProvider>()
        .aliPlayer;
    AliPlayerView aliPlayerView = AliPlayerView(
        onCreated: (int viewId) {
          aliPlayer.player.setPlayerView(viewId);
          if (aliPlayer.playerValue.status < 2) {
            aliPlayer.player.prepare();
          }
        },
        x: 0,
        y: 0,
        width: widget.width,
        height: widget.height);
    // TODO: implement build
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Stack(
          children: [
            Container(
              child: aliPlayerView,
            ),
            Visibility(
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                width: widget.width,
                height: widget.height,
                child: AliPlayerControls(
                  isFullScreen: widget.isFullScreen,
                  pushFullScreenFunction: widget.pushFullScreenFunction,
                  popFullScreenFunction: widget.popFullScreenFunction,
                ),
              ),
              visible: aliPlayer.playerValue.isPrepare,
            ),
          ],
        ),
      );
    });
  }
}

//播放器控制菜单
class AliPlayerControls extends StatefulWidget {
  final pushFullScreenFunction;
  final popFullScreenFunction;
  final bool isFullScreen;
  const AliPlayerControls(
      {Key key,
      this.pushFullScreenFunction,
      this.popFullScreenFunction,
      this.isFullScreen = false})
      : super(key: key);

  @override
  AliPlayerControlsState createState() {
    // TODO: implement createState
    return AliPlayerControlsState();
  }
}

class AliPlayerControlsState extends State<AliPlayerControls> {
  bool isShowControls = true;
  Timer _hideTimer;
  ASRAliPlayer aliPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _startTimer() {
    if (isShowControls && _hideTimer == null) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          isShowControls = false;
          _hideTimer.cancel();
          _hideTimer = null;
        });
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    aliPlayer = context
        .dependOnInheritedWidgetOfExactType<_AliPlayerViewProvider>()
        .aliPlayer;
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowControls = !isShowControls;
          if (isShowControls) {
            _startTimer();
          } else {
            if (_hideTimer != null) {
              _hideTimer.cancel();
              _hideTimer = null;
            }
          }
        });
      },
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedOpacity(
                opacity: isShowControls ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  color: Color(0x50000000),
                  height: 40,
                ),
              ),
              Expanded(
                  child: Container(
                color: Colors.transparent,
              )),
              AnimatedOpacity(
                opacity: isShowControls ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: Color(0x50000000),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            if (aliPlayer.playerValue.isPlaying) {
                              aliPlayer.player.pause();
                            } else {
                              aliPlayer.player.play();
                              if (aliPlayer.playerValue.status == 6 &&
                                  aliPlayer.playerValue.position ==
                                      aliPlayer.playerValue.duration) {
                                aliPlayer.player
                                    .seekTo(0, FlutterAvpdef.ACCURATE);
                              }
                            }
                          },
                          child: Container(
                            child: Icon(
                              aliPlayer.playerValue.isPlaying
                                  ? Icons.pause
                                  : Icons.play_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          )),
                      Container(
                        child: Text(
                          FormatterUtils.getTimeformatByMs(
                              aliPlayer.playerValue.position),
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: isShowControls
                              ? CupertinoVideoProgressBar(aliPlayer)
                              : Container()),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        child: Text(
                          FormatterUtils.getTimeformatByMs(
                              aliPlayer.playerValue.duration.floor()),
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            if (widget.pushFullScreenFunction != null &&
                                widget.isFullScreen == false) {
                              widget.pushFullScreenFunction();
                            }
                            if (widget.popFullScreenFunction != null &&
                                widget.isFullScreen == true) {
                              widget.popFullScreenFunction();
                            }
                          },
                          child: Container(
                            child: Icon(
                              widget.isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                              size: 25,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildProgressBar(),
        ],
      ),
    );
  }

  //缓冲进度
  _buildProgressBar() {
    if (aliPlayer.playerValue.isShowLoadingProgress != null &&
        aliPlayer.playerValue.isShowLoadingProgress) {
      return Center(
        child: LineSpinFadeLoaderIndicator(),
      );
    } else {
      return SizedBox();
    }
  }
}

//播放数据共享
class _AliPlayerViewProvider extends InheritedWidget {
  final ASRAliPlayer aliPlayer;
  _AliPlayerViewProvider({
    Key key,
    @required this.aliPlayer,
    @required Widget child,
  })  : assert(aliPlayer != null),
        assert(child != null),
        super(key: key, child: child);

  static _AliPlayerViewProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AliPlayerViewProvider>();
  }

  @override
  bool updateShouldNotify(_AliPlayerViewProvider oldWidget) {
    // TODO: implement updateShouldNotify
    return aliPlayer != oldWidget.aliPlayer;
  }
}

//进度条设置
class CupertinoVideoProgressBar extends StatefulWidget {
  CupertinoVideoProgressBar(
    this.aliPlayer, {
    ChewieProgressColors colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    Key key,
  })  : colors = colors ?? ChewieProgressColors(),
        super(key: key);

  final ASRAliPlayer aliPlayer;
  final ChewieProgressColors colors;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onDragUpdate;

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<CupertinoVideoProgressBar> {
  bool _controllerWasPlaying = false;

  ASRAliPlayer get controller => widget.aliPlayer;

  void seekToRelativePosition(Offset globalPosition) {
    setState(() {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx < 0
          ? 0
          : tapPos.dx > box.size.width
              ? 1
              : tapPos.dx / box.size.width;
      final double position = controller.playerValue.duration * relative;
      controller.playerValue.setValue(position: position.floor());
      controller.playerValue = controller.playerValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.playerValue.isPrepare) {
          return;
        }
        _controllerWasPlaying = controller.playerValue.isPlaying;
        if (_controllerWasPlaying) {
          controller.player.pause();
        }

        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.playerValue.isPrepare) {
          return;
        }
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.player.play();
        }
        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
        controller.player.seekTo(
            controller.playerValue.position.floor(), FlutterAvpdef.ACCURATE);
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.playerValue.isPrepare) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
        controller.player.seekTo(
            controller.playerValue.position.floor(), FlutterAvpdef.ACCURATE);
      },
      child: Center(
        child: Container(
          height: 40,
          width: double.infinity,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              controller.playerValue,
              widget.colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.colors);

  AliPlayerValue value;
  ChewieProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const barHeight = 5.0;
    const handleHeight = 6.0;
    final baseOffset = size.height / 2 - barHeight / 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!value.isPrepare) {
      return;
    }
    final double playedPartPercent = value.position / value.duration;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    final double bufferedPercent = value.buffered / value.duration;
    final double bufferdPart =
        bufferedPercent > 1 ? size.width : bufferedPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(playedPart, baseOffset),
          Offset(bufferdPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.bufferedPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(playedPart, baseOffset + barHeight / 2),
          radius: handleHeight));
    canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
    canvas.drawCircle(
      Offset(playedPart, baseOffset + barHeight / 2),
      handleHeight,
      colors.handlePaint,
    );
  }
}

class ChewieProgressColors {
  ChewieProgressColors({
    Color playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    Color bufferedColor = const Color.fromRGBO(30, 30, 200, 0.2),
    Color handleColor = const Color.fromRGBO(200, 200, 200, 1.0),
    Color backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  })  : playedPaint = Paint()..color = playedColor,
        bufferedPaint = Paint()..color = bufferedColor,
        handlePaint = Paint()..color = handleColor,
        backgroundPaint = Paint()..color = backgroundColor;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;
}

class MultiplePlayerBetweenPageA extends StatefulWidget {
  final String playerId;
  const MultiplePlayerBetweenPageA({Key key, this.playerId}) : super(key: key);

  @override
  _MultiplePlayerBetweenPageAState createState() =>
      _MultiplePlayerBetweenPageAState();
}

class _MultiplePlayerBetweenPageAState
    extends State<MultiplePlayerBetweenPageA> {
//   ASRAliPlayer player = ASRAliPlayer();

  @override
  void initState() {
    super.initState();
//    player.setPlayer('https://vcdn.jiazhangkj.com/sv/3f789d73-177ec4cc77f/3f789d73-177ec4cc77f.mp4', 'AAAAA',autoPlay: true);
  }

//  @override
//  void dispose() {
//    super.dispose();
//    player.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("多实例播放测试界面A"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: 1.sw,
            height: 1.sw * 9 / 16,
            child: ASRAliPlayerView(
              'https://vcdn.jiazhangkj.com/sv/3f789d73-177ec4cc77f/3f789d73-177ec4cc77f.mp4',
              1.sw,
              1.sw * 9 / 16,
            ),
          ),
        ],
      ),
    );
  }
}
