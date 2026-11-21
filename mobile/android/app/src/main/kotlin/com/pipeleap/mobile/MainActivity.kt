package com.pipeleap.mobile

import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.os.Debug
import io.flutter.embedding.android.FlutterActivity

/**
 * Release hardening that stays Play-Store friendly:
 * - no root bans / SafetyNet (false positives on legitimate devices)
 * - no signature pinning (breaks Play App Signing)
 * - block obvious debuggable / debugger-attached release builds
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        if (!BuildConfig.DEBUG) {
            val debuggable =
                (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
            if (debuggable || Debug.isDebuggerConnected()) {
                finishAffinity()
                return
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        if (!BuildConfig.DEBUG && Debug.isDebuggerConnected()) {
            finishAffinity()
        }
    }
}
