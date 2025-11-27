#!/bin/bash

# Clean previous build
rm -rf build
rm -rf Lumen.app
mkdir -p build

# Compile C++ Bridge
clang++ -c Lumen/MTPBridge.cpp -o build/MTPBridge.o \
  -std=c++17 \
  -I/opt/homebrew/include \
  -I/usr/local/include

# Compile all Swift files and link
swiftc -v -sdk $(xcrun --sdk macosx --show-sdk-path) \
  -import-objc-header Lumen/Lumen-Bridging-Header.h \
  -I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/ \
  -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/ \
  -I/opt/homebrew/include \
  -I/usr/local/include \
  -L/opt/homebrew/lib \
  -L/usr/local/lib \
  -lmtp \
  -lc++ \
  -framework Foundation \
  -framework AppKit \
  -framework SwiftUI \
  -framework UniformTypeIdentifiers \
  Lumen/*.swift build/MTPBridge.o \
  -o Lumen.app

echo "Build completed!"