package pl.merskip.qwallet

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Icon
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.service.notification.NotificationListenerService
import androidx.annotation.RequiresApi
import java.io.ByteArrayOutputStream

class PushNotificationsService : NotificationListenerService() {

    private val binder = LocalBinder()

    override fun onBind(intent: Intent): IBinder? {
        val action = intent.action
        return if (SERVICE_INTERFACE == action) super.onBind(intent) else binder
    }

    fun isPermissionGranted(): Boolean {
        return isNotificationServiceEnabled()
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val components = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                .split(':')
                .mapNotNull { ComponentName.unflattenFromString(it) }
        return components.any {
            it.packageName == packageName && it.className == this::class.java.name
        }
    }

    fun getActivePushNotifications(): List<PushNotification> {
        return activeNotifications.map { statusBarNotification ->
            val notification = statusBarNotification.notification
            val extras = notification.extras

            val smallIcon = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                notification.smallIcon?.toByteArray(this)
            } else null
            val largeIcon = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                notification.getLargeIcon()?.toByteArray(this)
            } else null

            PushNotification(
                    id = statusBarNotification.key,
                    title = extras.getString("android.title"),
                    text = extras.getString("android.text"),
                    smallIcon = smallIcon,
                    largeIcon = largeIcon,
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun Icon.toByteArray(context: Context): ByteArray? {
        val drawable = loadDrawable(context) as? BitmapDrawable
                ?: return null
        val bitmap: Bitmap = drawable.bitmap
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    data class PushNotification(
            val id: String,
            val title: String?,
            val text: String?,
            val smallIcon: ByteArray?,
            val largeIcon: ByteArray?
    )

    inner class LocalBinder : Binder() {

        fun getService() = this@PushNotificationsService
    }
}