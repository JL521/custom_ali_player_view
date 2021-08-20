# custom_ali_player_view

基于阿里播放器进行的二次封装和优化、完善优化阿里播放器

1、支持界面自定义宽高、随处可以使用
2、支持视频全屏播放、内部实现全屏逻辑
3、支持播放器多页面实例化
4、统一管理播放器，保证播放器ID的唯一性


## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

2.关闭国内镜像
我这里用的zsh，用bash的切换到.bash_profile文件

vim ~/.zshrc


export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
将PUB_HOSTED_URL和FLUTTER_STORAGE_BASE_URL注释掉
3.cd到写好的插件仓库根目录，执行一次

flutter packages get
这时候就会把你的插件里的lock文件中的国内镜像转到官方源上了
4.正常使用
sudo flutter packages pub publish -v
或
flutter packages pub publish --server=https://pub.dartlang.org
即可
