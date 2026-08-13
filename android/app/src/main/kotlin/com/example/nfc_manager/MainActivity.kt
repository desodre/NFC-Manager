package com.example.nfc_manager

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var nfcAdapter: NfcAdapter? = null
    private lateinit var nfcPendingIntent: PendingIntent
    private lateinit var nfcFilters: Array<IntentFilter>

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        nfcPendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )

        nfcFilters = arrayOf(IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED).apply {
            addCategory(Intent.CATEGORY_DEFAULT)
        })
    }

    override fun onResume() {
        super.onResume()
        // Keeps NDEF URI/Wi-Fi intents inside this foreground Activity instead
        // of allowing Android to launch another application.
        nfcAdapter?.enableForegroundDispatch(this, nfcPendingIntent, nfcFilters, null)
    }

    override fun onPause() {
        nfcAdapter?.disableForegroundDispatch(this)
        super.onPause()
    }

    override fun onNewIntent(intent: Intent) {
        // Consume NFC intents while the app is in the foreground. The Flutter
        // nfc_manager session receives the tag through reader mode.
        setIntent(intent)
    }
}
