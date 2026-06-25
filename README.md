# Minimal Android APK - GitHub Actions 自动构建

一个最简单的 Android APK 项目，通过 GitHub Actions 自动编译。

## 使用方法

1. Fork 或创建新仓库，将本目录所有文件推送上去
2. GitHub Actions 会自动触发构建
3. 在 Actions 页面的构建结果中下载 APK（Artifacts → miniapp）
4. 也可手动触发：Actions → Build APK → Run workflow

## 本地构建（需要 Android SDK）

```bash
export ANDROID_HOME=/path/to/android-sdk
bash build.sh
```

## 项目结构

```
├── AndroidManifest.xml
├── src/com/example/miniapp/MainActivity.java
├── build.sh
└── .github/workflows/build.yml
```
