package com.example.budayago

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "=== MainActivity onCreate ===")
        
        // ✅ Handle initial deep link
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "=== MainActivity onNewIntent ===")
        Log.d(TAG, "Intent Action: ${intent.action}")
        Log.d(TAG, "Intent Data: ${intent.data}")
        
        // ✅ Update intent & handle
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) {
            Log.d(TAG, "Intent is null")
            return
        }

        val action = intent.action
        val data = intent.data

        Log.d(TAG, "=== handleIntent ===")
        Log.d(TAG, "Action: $action")
        Log.d(TAG, "Data: $data")

        // ✅ Check if this is a deep link
        if (action == Intent.ACTION_VIEW && data != null) {
            Log.d(TAG, "=== DEEP LINK DETECTED ===")
            Log.d(TAG, "Full URI: $data")
            Log.d(TAG, "Scheme: ${data.scheme}")
            Log.d(TAG, "Host: ${data.host}")
            Log.d(TAG, "Path: ${data.path}")
            
            try {
                // ✅ SAFE: Check if hierarchical before getting query params
                if (data.isHierarchical) {
                    Log.d(TAG, "Query: ${data.query}")
                    
                    // Extract query parameters
                    val code = data.getQueryParameter("code")
                    val type = data.getQueryParameter("type")
                    
                    Log.d(TAG, "Code: $code")
                    Log.d(TAG, "Type: $type")
                    
                    // ✅ Supabase will handle this automatically via app_links plugin
                    // No need to manually parse or redirect
                    Log.d(TAG, "✅ Deep link will be handled by Supabase auth listener")
                } else {
                    // ✅ Non-hierarchical URI (e.g., "budayago:" without authority)
                    Log.d(TAG, "⚠️ Non-hierarchical URI detected")
                    Log.d(TAG, "URI: $data")
                    
                    // Try to extract code manually from query string
                    val uriString = data.toString()
                    if (uriString.contains("code=")) {
                        val code = uriString.substringAfter("code=").substringBefore("&")
                        Log.d(TAG, "Extracted code: $code")
                    }
                    
                    // ✅ Let Supabase handle it
                    Log.d(TAG, "✅ Passing to Supabase auth handler")
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error handling deep link: ${e.message}", e)
                // ✅ Don't crash - just log and continue
            }
        } else {
            Log.d(TAG, "Not a deep link intent")
        }
    }
}
