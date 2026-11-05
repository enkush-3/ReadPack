package com.example.readpact

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val quoteText = prefs.getString("flutter.phone_widget_quote_text", "\"Унших нь оюун санааны хувьд дасгал хийхтэй адил.\"")
            ?: "\"Унших нь оюун санааны хувьд дасгал хийхтэй адил.\""
        val author = prefs.getString("flutter.phone_widget_author", "Жозеф Аддисон") ?: "Жозеф Аддисон"
        val book = prefs.getString("flutter.phone_widget_book", "Сонгодог бүтээл") ?: "ReadPack"
        val source = prefs.getString("flutter.phone_widget_source", "daily") ?: "daily"

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quote)

            val badgeText = if (source == "saved") "📌 ХАДГАЛСАН ЭШЛЭЛ" else "📖 ӨДРИЙН ЭШЛЭЛ"
            views.setTextViewText(R.id.widget_badge, badgeText)
            views.setTextViewText(R.id.widget_quote_text, quoteText)
            views.setTextViewText(R.id.widget_author, "— $author · $book")

            // Launch app when tapped
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
