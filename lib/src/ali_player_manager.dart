import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';

//统一管理阿里播放器、控制监听
Map<String, ASRAliPlayer> players = {};
int playerID = 0; //保证全局playerId不能重复
//暂停播放控制
void stopAliPlayers() {
  players.forEach((key, value) {
    if (value != null) {
      value.player.pause();
    }
  });
}

class ASRAliPlayer {
  FlutterAliplayer player;
  AliPlayerValue playerValue;

  void setPlayer(String url, {bool autoPlay = true}) {
    stopAliPlayers();
    String playerId = 'aliPlayer_$playerID';
    player = FlutterAliPlayerFactory.createAliPlayer(playerId: playerId);
    player.setAutoPlay(autoPlay);
    player.setUrl(url);
    playerValue = AliPlayerValue();
    players[playerId] = this;
    playerID = playerID + 1;
    initListener();
  }

  initListener() {
    player.setOnPrepared((playerId) {
      players[playerId].player.getMediaInfo().then((info) {
        print("视频信息===" + info.toString());
        int duration = info['duration'];
        players[playerId].playerValue.setValue(
            position: 0, duration: duration.floorToDouble(), isPrepare: true);
        players[playerId].player.seekTo(0, FlutterAvpdef.ACCURATE);
      });
    });
    player.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      print('playerId====$playerId ======== $extraValue ====$infoCode');
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        players[playerId].playerValue.setValue(position: extraValue);
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        players[playerId].playerValue.setValue(buffered: extraValue);
      }
    });
    player.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      players[playerId].playerValue.setValue(isShowLoadingProgress: false);
    });
    player.setOnStateChanged((newState, playerId) {
      if (newState == FlutterAvpdef.started) {
        players[playerId]
            .playerValue
            .setValue(isShowLoadingProgress: false, isPlaying: true);
      } else {
        players[playerId].playerValue.setValue(isPlaying: false);
      }
      players[playerId].playerValue.setValue(status: newState);
      if (newState == FlutterAvpdef.completion) {
        players[playerId].player.seekTo(0, FlutterAvpdef.ACCURATE);
      }
    });
    player.setOnLoadingStatusListener(loadingBegin: (playerId) {
      players[playerId].playerValue.setValue(isShowLoadingProgress: true);
    }, loadingProgress: (percent, netSpeed, playerId) {
      if (percent == 100) {
        players[playerId].playerValue.setValue(isShowLoadingProgress: false);
      }
    }, loadingEnd: (playerId) {
      players[playerId].playerValue.setValue(isShowLoadingProgress: false);
    });
    player.setOnCompletion((playerId) {
      players[playerId].playerValue.setValue(isShowLoadingProgress: false);
    });
  }

  dispose() {
    player.stop();
    player.destroy();
    players.remove(this);
  }
}

class AliPlayerValue with ChangeNotifier {
  bool isPrepare;
  bool isPlaying;
  int position;
  double duration;
  int buffered;
  int status;
  double aspectRatio;
  double videoWidth;
  double videoHeight;
  bool isShowLoadingProgress;
  String playerId;

  AliPlayerValue(
      {int position = 0,
      int status = 0,
      bool isPrepare = false,
      bool isPlaying = false,
      double duration = 0,
      int buffered = 0,
      double aspectRatio = 1,
      double videoWidth,
      double videoHeight,
      bool isShowLoadingProgress = false,
      String playerId}) {
    this.position = position;
    this.status = status;
    this.isPrepare = isPrepare;
    this.isPlaying = isPlaying;
    this.duration = duration;
    this.buffered = buffered;
    this.aspectRatio = aspectRatio;
    this.videoHeight = videoHeight;
    this.videoWidth = videoWidth;
    this.isShowLoadingProgress = isShowLoadingProgress;
    this.playerId = playerId;
  }

  void setValue(
      {int position,
      int status,
      bool isPrepare,
      bool isPlaying,
      double duration,
      int buffered,
      double aspectRatio,
      double videoWidth,
      double videoHeight,
      bool isShowLoadingProgress,
      String playerId}) {
    if (position != null) {
      this.position = position;
    }
    if (status != null) {
      this.status = status;
    }
    if (isPrepare != null) {
      this.isPrepare = isPrepare;
    }
    if (isPlaying != null) {
      this.isPlaying = isPlaying;
    }
    if (duration != null) {
      this.duration = duration;
    }
    if (buffered != null) {
      this.buffered = buffered;
    }
    if (aspectRatio != null) {
      this.aspectRatio = aspectRatio;
    }
    if (videoWidth != null) {
      this.videoWidth = videoWidth;
    }
    if (videoHeight != null) {
      this.videoHeight = videoHeight;
    }
    if (isShowLoadingProgress != null) {
      this.isShowLoadingProgress = isShowLoadingProgress;
    }
    if (playerId != null) {
      this.playerId = playerId;
    }
    notifyListeners();
  }
}
