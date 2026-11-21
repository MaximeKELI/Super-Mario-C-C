package com.pipeleap.mobile

import android.content.pm.ApplicationInfo
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Refuse to run if a release build was re-signed / patched as debuggable.
        if (!BuildConfig.DEBUG) {
            val debuggable =
                (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
            if (debuggable) {
                finishAffinity()
                return
            }
        }
        super.onCreate(savedInstanceState)
    }
}
