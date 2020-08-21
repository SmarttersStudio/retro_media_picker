package com.example.retro_media_picker

import android.content.Context
import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** RetroMediaPickerPlugin */
public class RetroMediaPickerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "retro_media_picker")
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "retro_media_picker")
      channel.setMethodCallHandler(RetroMediaPickerPlugin())
    }
  }
  private val executor: ExecutorService = Executors.newFixedThreadPool(1)
  private val mainHandler by lazy { Handler(context.mainLooper) }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getAlbums") {
      val withImages = call.argument<Boolean>("withImages")
      val withVideos = call.argument<Boolean>("withVideos")
      if (withImages == null || withVideos == null) {
        result.error("INVALID_ARGUMENTS", "withImages or withVideos must not be null", null)
        return
      }
      val albums = FileFetcher.getAlbums(context, withImages, withVideos)
      result.success(albums.toString())
    }
    else if (call.method == "getThumbnail") {
      val fileId = call.argument<String>("fileId")
      val type = call.argument<Int>("type")
      if (fileId == null || type == null) {
        result.error("INVALID_ARGUMENTS", "fileId or type must not be null", null)
        return
      }
      executor.execute {
        try {
          val thumbnail = FileFetcher.getThumbnail(
                  context,
                  fileId.toLong(),
                  MediaFile.MediaType.values()[type]
          )
          mainHandler.post {
            if (thumbnail != null)
              result.success(thumbnail)
            else
              result.error("NOT_FOUND", "Unable to get the thumbnail", null)
          }
        } catch (e: Exception) {
          Log.e("MediaPickerBuilder", e.message.toString())
          mainHandler.post {
            result.error("GENERATE_THUMBNAIL_FAILED", "Unable to generate thumbnail ${e.message}", null)
          }
        }
      }
    }
    else if (call.method == "getMediaFile") {
      val fileIdString = call.argument<String>("fileId")
      val type = call.argument<Int>("type")
      val loadThumbnail = call.argument<Boolean>("loadThumbnail")
      if (fileIdString == null || type == null || loadThumbnail == null) {
        result.error("INVALID_ARGUMENTS", "fileId, type or loadThumbnail must not be null", null)
        return
      }

      val fileId = fileIdString.toLongOrNull()
      if (fileId == null) {
        result.error("NOT_FOUND", "Unable to find the file", null)
        return
      }

      executor.execute {
        try {
          val mediaFile = FileFetcher.getMediaFile(
                  context,
                  fileId,
                  MediaFile.MediaType.values()[type],
                  loadThumbnail)
          mainHandler.post {
            if (mediaFile != null)
              result.success(mediaFile.toJSONObject().toString())
            else
              result.error("NOT_FOUND", "Unable to find the file", null)
          }
        } catch (e: Exception) {
          Log.e("MediaPickerBuilder", e.message.toString())
          mainHandler.post {
            result.error("GENERATE_THUMBNAIL_FAILED", "Unable to generate thumbnail ${e.message}", null)
          }
        }
      }
    }
    else result.notImplemented()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
