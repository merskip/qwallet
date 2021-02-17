package pl.merskip.QWallet

import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class PushNotificationsService : NotificationListenerService() {

    private val binder = LocalBinder()

    override fun onBind(intent: Intent): IBinder? {
        val action = intent.action
        return if (SERVICE_INTERFACE == action) super.onBind(intent) else binder
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        val actives = activeNotifications.toList()

        for (statusBarNotification in actives) {
            println("### -- Notification from ${statusBarNotification.packageName}")
            val notification = statusBarNotification.notification
            println(notification)
            for (key in notification.extras.keySet()) {
                println(" - $key = " + notification.extras[key])
            }
        }

    }

    fun getActivePushNotifications(): List<PushNotification> {
        return activeNotifications.map { statusBarNotification ->
            val extras = statusBarNotification.notification.extras
            PushNotification(
                    id = statusBarNotification.key,
                    title = extras.getString("android.title"),
                    text = extras.getString("android.text"),
            )
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
    }

    data class PushNotification(
            val id: String,
            val title: String?,
            val text: String?
    )

    inner class LocalBinder : Binder() {

        fun getService() = this@PushNotificationsService
    }
}