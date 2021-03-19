package pl.merskip.qwallet

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private lateinit var pushNotificationsService: PushNotificationsService
    private var requestPermissionCallback: ((isGranted: Boolean) -> Unit)? = null

    private val connection = object : ServiceConnection {

        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            if (service is PushNotificationsService.LocalBinder)
                pushNotificationsService = service.getService()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startService(Intent(this, PushNotificationsService::class.java))
    }

    override fun onStart() {
        super.onStart()
        Intent(this, PushNotificationsService::class.java).also { intent ->
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    override fun onStop() {
        super.onStop()
        unbindService(connection)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "pl.merskip.qwallet/push_notification_service")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getActivePushNotifications" -> handleGetActiveNotifications(call, result)
                "isPermissionGranted" -> handleIsPermissionGranted(call, result)
                "requestPermission" -> handleRequestPermission(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleGetActiveNotifications(call: MethodCall, result: MethodChannel.Result) {
        try {
            val notifications = pushNotificationsService.getActivePushNotifications()
            result.success(mapOf(
                "notifications" to notifications.map {
                    mapOf(
                        "id" to it.id,
                        "title" to it.title,
                        "text" to it.text,
                        "smallIcon" to it.smallIcon,
                        "largeIcon" to it.largeIcon
                    )
                }
            ))
        } catch (e: Exception) {
            result.error("FAILED", "Failed get active push notification", e)
        }
    }

    private fun handleIsPermissionGranted(call: MethodCall, result: MethodChannel.Result) {
        try {
            val isPermissionGranted = pushNotificationsService.isPermissionGranted()
            result.success(
                mapOf(
                    "isPermissionGranted" to isPermissionGranted
                )
            )
        } catch (e: Exception) {
            result.error("FAILED", "Failed check isPermissionGranted", e)
        }
    }

    private fun handleRequestPermission(call: MethodCall, result: MethodChannel.Result) {
        try {
            requestPermission { isPermissionGranted ->
                result.success(
                    mapOf(
                        "isPermissionGranted" to isPermissionGranted
                    )
                )
            }
        } catch (e: Exception) {
            result.error("FAILED", "Failed check isPermissionGranted", e)
        }
    }

    private fun requestPermission(callback: (isGranted: Boolean) -> Unit) {
        if (pushNotificationsService.isPermissionGranted()) {
            callback(true)
        } else {
            requestPermissionCallback = callback
            startActivityForResult(Intent(notificationPermissionSettings), notificationPermissionRequest)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == notificationPermissionRequest) {
            requestPermissionCallback?.invoke(pushNotificationsService.isPermissionGranted())
            requestPermissionCallback = null
        }
    }

    companion object {
        private const val notificationPermissionRequest = 1
        private const val notificationPermissionSettings = "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"
    }
}
