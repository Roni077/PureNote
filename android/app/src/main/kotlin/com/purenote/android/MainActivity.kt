package com.purenote.android

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import android.view.WindowManager

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)
    }
}
