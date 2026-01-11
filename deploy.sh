#!/bin/bash

ADB="/Users/s312/Library/Android/sdk/platform-tools/adb"
APK="build/app/outputs/flutter-apk/app-release.apk"

echo "🔨 Сборка APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Сборка завершена"

    # Проверка подключения устройства
    DEVICE=$($ADB devices | grep -w "device" | head -1)

    if [ -z "$DEVICE" ]; then
        echo "❌ Устройство не подключено"
        exit 1
    fi

    echo "📱 Установка на устройство..."
    $ADB install -r $APK

    if [ $? -eq 0 ]; then
        echo "✅ Установка завершена!"

        # Запуск приложения
        echo "🚀 Запуск приложения..."
        $ADB shell am start -n com.example.clothing_dashboard/.MainActivity
    else
        echo "❌ Ошибка установки"
        exit 1
    fi
else
    echo "❌ Ошибка сборки"
    exit 1
fi
