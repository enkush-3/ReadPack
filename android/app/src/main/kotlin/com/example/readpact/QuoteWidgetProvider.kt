package com.example.readpact

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.widget.RemoteViews

class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, QuoteWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            for (widgetId in appWidgetIds) {
                updateSingleWidget(context, appWidgetManager, widgetId)
            }
        }

        private fun updateSingleWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            val rawQuote = prefs.getString("flutter.widget_quote_text", null)
                ?: prefs.getString("flutter.phone_widget_quote_text", null)
                ?: "Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг."
            val cleanQuote = rawQuote.trim().removeSurrounding("\"").removeSurrounding("“", "”")
            val quoteText = "“$cleanQuote”"

            val author = prefs.getString("flutter.widget_quote_author", null)
                ?: prefs.getString("flutter.phone_widget_author", null)
                ?: "Жорж Р.Р. Мартин"
            val book = prefs.getString("flutter.widget_quote_book", null)
                ?: prefs.getString("flutter.phone_widget_book", null)
                ?: "ReadPack"

            val sourceMode = prefs.getString("flutter.widget_quote_source", null)
                ?: prefs.getString("flutter.phone_widget_source", "daily")
                ?: "daily"

            // Theme mode: "system", "light", or "dark"
            val themeSetting = prefs.getString("flutter.widget_quote_theme_mode", "system") ?: "system"
            val isSystemDark = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
            val useDark = when (themeSetting) {
                "dark" -> true
                "light" -> false
                else -> isSystemDark
            }

            val views = RemoteViews(context.packageName, R.layout.widget_quote)

            // Apply background & colors according to Light / Dark theme
            if (useDark) {
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_bg_dark)
                views.setTextColor(R.id.widget_badge, Color.parseColor("#FBBF24"))
                views.setTextColor(R.id.widget_app_label, Color.parseColor("#94A3B8"))
                views.setTextColor(R.id.widget_quote_text, Color.parseColor("#F8FAFC"))
                views.setTextColor(R.id.widget_author, Color.parseColor("#CBD5E1"))
            } else {
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_bg_light)
                views.setTextColor(R.id.widget_badge, Color.parseColor("#9A6B26"))
                views.setTextColor(R.id.widget_app_label, Color.parseColor("#64748B"))
                views.setTextColor(R.id.widget_quote_text, Color.parseColor("#1E293B"))
                views.setTextColor(R.id.widget_author, Color.parseColor("#475569"))
            }

            val badgeText = if (sourceMode == "saved" || sourceMode == "custom") {
                "📌 ХАДГАЛСАН ИШЛЭЛ"
            } else {
                "📖 ӨДРИЙН ЭШЛЭЛ"
            }
            views.setTextViewText(R.id.widget_badge, badgeText)
            views.setTextViewText(R.id.widget_quote_text, quoteText)

            val footerText = if (book.isNotEmpty() && book != author) {
                "— $author · $book"
            } else {
                "— $author"
            }
            views.setTextViewText(R.id.widget_author, footerText)

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
