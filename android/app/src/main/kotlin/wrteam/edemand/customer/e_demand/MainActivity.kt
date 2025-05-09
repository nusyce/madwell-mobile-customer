package app.madwell.pro.customer

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Build;
import android.view.WindowManager
import android.util.Log;
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.MapsInitializer.Renderer
import com.google.android.gms.maps.OnMapsSdkInitializedCallback
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity(), OnMapsSdkInitializedCallback {
    private val ENVIRONMENT_CHANNEL = "app.madwell.pro.customer/android_environment"
    
    override
    fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MapsInitializer.initialize(applicationContext, Renderer.LATEST, this)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENVIRONMENT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getEnvironmentVariables") {
                // Handle environment variables from Flutter
                handleEnvironmentVariables(call.arguments as? Map<String, Any>, result)
            } else {
                result.notImplemented()
            }
        }
    }
    
    private fun handleEnvironmentVariables(envMap: Map<String, Any>?, result: MethodChannel.Result) {
        if (envMap == null) {
            result.error("ENV_ERROR", "Environment variables map is null", null)
            return
        }
        
        try {
            Log.d("EnvVars", "Received environment variables: ${envMap.keys}")
            
            // You can use these environment variables in your native code
            // For example, if you need to use them in a native component
            
            // Note: Google Maps and AdMob keys are already set in AndroidManifest.xml
            // by the update_manifest.sh script
            
            result.success(true)
        } catch (e: Exception) {
            Log.e("EnvVars", "Error handling environment variables", e)
            result.error("ENV_ERROR", "Error handling environment variables: ${e.message}", null)
        }
    }

    override fun onMapsSdkInitialized(renderer: MapsInitializer.Renderer) {
        when (renderer) {
            Renderer.LATEST -> Log.d(
                "NewRendererLog",
                "The latest version of the renderer is used."
            )
            Renderer.LEGACY -> Log.d(
                "NewRendererLog",
                "The legacy version of the renderer is used."
            )
        }
    }
}
