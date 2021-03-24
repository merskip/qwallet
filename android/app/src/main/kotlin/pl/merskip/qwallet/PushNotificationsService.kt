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
                    title = extras.get("android.title").toString(),
                    text = extras.get("android.text").toString(),
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
    ) {
        override fun equals(other: Any?): Boolean {
            // Generated
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as PushNotification

            if (id != other.id) return false
            if (title != other.title) return false
            if (text != other.text) return false
            if (smallIcon != null) {
                if (other.smallIcon == null) return false
                if (!smallIcon.contentEquals(other.smallIcon)) return false
            } else if (other.smallIcon != null) return false
            if (largeIcon != null) {
                if (other.largeIcon == null) return false
                if (!largeIcon.contentEquals(other.largeIcon)) return false
            } else if (other.largeIcon != null) return false

            return true
        }

        override fun hashCode(): Int {
            // Generated
            var result = id.hashCode()
            result = 31 * result + (title?.hashCode() ?: 0)
            result = 31 * result + (text?.hashCode() ?: 0)
            result = 31 * result + (smallIcon?.contentHashCode() ?: 0)
            result = 31 * result + (largeIcon?.contentHashCode() ?: 0)
            return result
        }
    }

    inner class LocalBinder : Binder() {

        fun getService() = this@PushNotificationsService
    }
}