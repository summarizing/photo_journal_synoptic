package com.example.photo_journal

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.photojournal/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceModel" -> {
                    // Build.MODEL gives us the device model e.g. "Pixel 7"
                    // Build.MANUFACTURER gives us e.g. "Google"
                    val model = "${Build.MANUFACTURER} ${Build.MODEL}"
                    result.success(model)
                }
                else -> result.notImplemented()
            }
        }
    }
}
