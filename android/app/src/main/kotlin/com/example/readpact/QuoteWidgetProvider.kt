package com.example.readpact

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Build
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
            val cleanQuote = rawQuote
                ?.trim()
                ?.removeSurrounding("\"")
                ?.removeSurrounding("“", "”")
                .orEmpty()
            val quoteText = cleanQuote.takeIf { it.isNotBlank() }?.let { "“$it”" }

            val author = prefs.getString("flutter.widget_quote_author", null)
                ?: prefs.getString("flutter.phone_widget_author", null)
                ?: ""
            val book = prefs.getString("flutter.widget_quote_book", null)
                ?: prefs.getString("flutter.phone_widget_book", null)
                ?: ""

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
            val languageCode = prefs.getString("flutter.widget_quote_language", null)
                ?: prefs.getString("flutter.readpack_locale", "mn")
                ?: "mn"
            val lightSurface = prefs.getInt("flutter.widget_quote_color_surface", Color.parseColor("#FFFBFE"))
            val darkSurface = prefs.getInt("flutter.widget_quote_color_surfaceContainer", Color.parseColor("#1D1B20"))
            val primaryColor = prefs.getInt("flutter.widget_quote_color_primary", Color.parseColor("#6750A4"))
            val onSurfaceColor = prefs.getInt(
                "flutter.widget_quote_color_onSurface",
                if (useDark) Color.parseColor("#E6E1E5") else Color.parseColor("#1D1B20")
            )
            val secondaryColor = prefs.getInt(
                "flutter.widget_quote_color_secondary",
                if (useDark) Color.parseColor("#CAC4D0") else Color.parseColor("#49454F")
            )

            // Apply background & colors according to Light / Dark theme
            if (useDark) {
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_bg_dark)
                views.setTextColor(R.id.widget_badge, primaryColor)
            } else {
                views.setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_bg_light)
                views.setTextColor(R.id.widget_badge, primaryColor)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val surfaceColor = if (useDark) darkSurface else lightSurface
                views.setColorStateList(
                    R.id.widget_root,
                    "setBackgroundTintList",
                    ColorStateList.valueOf(surfaceColor)
                )
            }
            views.setTextColor(R.id.widget_app_label, secondaryColor)
            views.setTextColor(R.id.widget_quote_text, onSurfaceColor)
            views.setTextColor(R.id.widget_author, secondaryColor)

            val badgeText = if (sourceMode == "saved" || sourceMode == "custom") {
                if (languageCode == "en") "📌 SAVED QUOTE" else "📌 ХАДГАЛСАН ИШЛЭЛ"
            } else {
                if (languageCode == "en") "📖 DAILY QUOTE" else "📖 ӨДРИЙН ЭШЛЭЛ"
            }
            views.setTextViewText(R.id.widget_badge, badgeText)
            views.setTextViewText(
                R.id.widget_quote_text,
                quoteText ?: if (languageCode == "en") {
                    "Open ReadPack and choose a quote for this widget."
                } else {
                    "ReadPack-ийг нээгээд виджетэд ишлэл сонгоно уу."
                }
            )

            val footerText = if (quoteText == null) {
                if (languageCode == "en") "Tap to choose a quote" else "Ишлэл сонгохын тулд товшино уу"
            } else if (book.isNotEmpty() && book != author) {
                "— $author · $book"
            } else if (author.isNotEmpty()) {
                "— $author"
            } else {
                ""
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
