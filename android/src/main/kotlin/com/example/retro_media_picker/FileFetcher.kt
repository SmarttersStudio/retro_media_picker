package com.example.retro_media_picker

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import org.json.JSONArray
import java.io.File

class FileFetcher {
    companion object {
        private val imageMediaColumns = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DATE_ADDED,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID,
                MediaStore.Images.Media.ORIENTATION,
                MediaStore.Images.Media.MIME_TYPE)

        private val videoMediaColumns = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.DATE_ADDED,
                MediaStore.Video.Media.DATA,
                MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Video.Media.BUCKET_ID,
                MediaStore.Video.Media.MIME_TYPE,
                MediaStore.Video.Media.DURATION)

        fun getAlbums(context: Context, withImages: Boolean, withVideos: Boolean): JSONArray {
            val albumHashMap: MutableMap<Long, Album> = LinkedHashMap()

            if (withImages)
                fetchImages(context, albumHashMap)

            if (withVideos)
                fetchVideos(context, albumHashMap)

            fetchThumbnails(context, albumHashMap, withImages, withVideos)

            albumHashMap.values.forEach { album ->
                album.files.sortByDescending { file ->
                    file.dateAdded
                }
            }

            return JSONArray(albumHashMap.values.map { it.toJSONObject() })
        }

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        @Throws(Exception::class)
        fun getMediaFile(context: Context, fileId: Long, type: MediaFile.MediaType, loadThumbnail: Boolean): MediaFile? {
            var mediaFile: MediaFile? = null
            when (type) {
                MediaFile.MediaType.IMAGE -> {
                    context.contentResolver.query(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            imageMediaColumns,
                            "${MediaStore.Images.Media._ID} = $fileId",
                            null,
                            null)?.use { cursor ->

                        if (cursor.count > 0) {
                            cursor.moveToFirst()
                            mediaFile = getMediaFile(cursor, MediaFile.MediaType.IMAGE)
                            if (mediaFile?.thumbnailPath != null && !File(mediaFile?.thumbnailPath).exists()) {
                                mediaFile?.thumbnailPath = null
                            }
                            if (mediaFile?.thumbnailPath == null && loadThumbnail) {
                                mediaFile?.thumbnailPath = getThumbnail(context, fileId, type)
                            }
                        }
                    }
                }
                MediaFile.MediaType.VIDEO -> {
                    context.contentResolver.query(
                            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                            videoMediaColumns,
                            "${MediaStore.Video.Media._ID} = $fileId",
                            null,
                            null)?.use { cursor ->

                        if (cursor.count > 0) {
                            cursor.moveToFirst()
                            mediaFile = getMediaFile(cursor, MediaFile.MediaType.VIDEO)
                            if (mediaFile?.thumbnailPath != null && !File(mediaFile?.thumbnailPath).exists()) {
                                mediaFile?.thumbnailPath = null
                            }
                            if (mediaFile?.thumbnailPath == null && loadThumbnail) {
                                mediaFile?.thumbnailPath = getThumbnail(context, fileId, type)
                            }
                        }
                    }

                }
            }
            return mediaFile
        }

        private fun fetchImages(context: Context, albumHashMap: MutableMap<Long, Album>) {
            context.contentResolver.query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    imageMediaColumns
                    , null,
                    null,
                    "${MediaStore.Images.Media._ID} DESC")?.use { cursor ->

                while (cursor.moveToNext()) {
                    val mediaFile = getMediaFile(cursor, MediaFile.MediaType.IMAGE)
                    val album = albumHashMap[mediaFile.albumId]
                    if (album == null) {
                        albumHashMap[mediaFile.albumId] = Album(
                                mediaFile.albumId,
                                mediaFile.albumName,
                                mutableListOf(mediaFile)
                        )
                    } else {
                        album.files.add(mediaFile)
                    }
                }
            }
        }

        private fun fetchVideos(context: Context, albumHashMap: MutableMap<Long, Album>) {
            context.contentResolver.query(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                    videoMediaColumns
                    , null,
                    null,
                    "${MediaStore.Video.Media._ID} DESC")?.use { cursor ->

                while (cursor.moveToNext()) {
                    val mediaFile = getMediaFile(cursor, MediaFile.MediaType.VIDEO)
                    val album = albumHashMap[mediaFile.albumId]
                    if (album == null) {
                        albumHashMap[mediaFile.albumId] = Album(
                                mediaFile.albumId,
                                mediaFile.albumName,
                                mutableListOf(mediaFile)
                        )
                    } else {
                        album.files.add(mediaFile)
                    }
                }
            }
        }

        private fun getMediaFile(cursor: Cursor, type: MediaFile.MediaType): MediaFile {
            when (type) {
                MediaFile.MediaType.VIDEO -> {
                    val fileId = cursor.getLong(0)          //MediaStore.Video.Media._ID
                    val fileDateAdded = cursor.getLong(1)   //MediaStore.Video.Media.DATE_ADDED
                    val filePath = cursor.getString(2)      //MediaStore.Video.Media.DATA
                    val albumName = cursor.getString(3)     //MediaStore.Video.Media.BUCKET_DISPLAY_NAME
                    val albumId = cursor.getLong(4)         //MediaStore.Video.Media.BUCKET_ID
                    val mimeType = cursor.getString(5)      //MediaStore.Video.Media.MIME_TYPE
                    val duration = cursor.getLong(6)        //MediaStore.Video.Media.DURATION

                    return MediaFile(
                            fileId,
                            albumId,
                            albumName,
                            fileDateAdded,
                            filePath,
                            null,
                            0,
                            mimeType,
                            duration,
                            type
                    )
                }
                MediaFile.MediaType.IMAGE -> {
                    val fileId = cursor.getLong(0)          //MediaStore.Images.Media._ID
                    val fileDateAdded = cursor.getLong(1)   //MediaStore.Images.Media.DATE_ADDED
                    val filePath = cursor.getString(2)      //MediaStore.Images.Media.DATA
                    val albumName = cursor.getString(3)     //MediaStore.Images.Media.BUCKET_DISPLAY_NAME
                    val albumId = cursor.getLong(4)         //MediaStore.Images.Media.BUCKET_ID
                    val orientation = cursor.getInt(5)      //MediaStore.Images.Media.ORIENTATION
                    val mimeType = cursor.getString(6)      //MediaStore.Images.Media.MIME_TYPE

                    return MediaFile(
                            fileId,
                            albumId,
                            albumName,
                            fileDateAdded,
                            filePath,
                            null,
                            orientation,
                            mimeType,
                            null,
                            type
                    )
                }
            }
        }

        private fun fetchThumbnails(context: Context,
                                    albumHashMap: MutableMap<Long, Album>,
                                    withImages: Boolean,
                                    withVideos: Boolean) {

            if (withImages)
                context.contentResolver.query(
                        MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI,
                        arrayOf(
                                MediaStore.Images.Thumbnails.IMAGE_ID,
                                MediaStore.Images.Thumbnails.DATA
                        ),
                        null,
                        null,
                        null)?.use { cursor ->
                    while (cursor.moveToNext()) {
                        val fileId = cursor.getLong(0)
                        var thumbnail = cursor.getString(1)

                        // Set the thumbnail to null if it doesn't exist
                        if (!File(thumbnail).exists())
                            thumbnail = null

                        if (thumbnail != null)
                            for (album in albumHashMap.values) {
                                val file = album.files.firstOrNull { it.id == fileId }
                                if (file != null) {
                                    file.thumbnailPath = thumbnail
                                    break
                                }
                            }
                    }

                }

            if (withVideos)
                context.contentResolver.query(
                        MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI,
                        arrayOf(
                                MediaStore.Video.Thumbnails.VIDEO_ID,
                                MediaStore.Video.Thumbnails.DATA
                        ),
                        null,
                        null,
                        null)?.use { cursor ->

                    val fileIdColumn = cursor.getColumnIndex(MediaStore.Video.Thumbnails.VIDEO_ID)
                    val thumbnailPathColumn = cursor.getColumnIndex(MediaStore.Video.Thumbnails.DATA)
                    while (cursor.moveToNext()) {
                        val fileId = cursor.getLong(fileIdColumn)
                        var thumbnail = cursor.getString(thumbnailPathColumn)

                        // Set the thumbnail to null if it doesn't exist
                        if (!File(thumbnail).exists())
                            thumbnail = null

                        if (thumbnail != null)
                            for (album in albumHashMap.values) {
                                val file = album.files.firstOrNull { it.id == fileId }
                                if (file != null) {
                                    file.thumbnailPath = thumbnail
                                    break
                                }
                            }
                    }
                }
        }

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        @Throws(Exception::class)
        fun getThumbnail(context: Context, fileId: Long, type: MediaFile.MediaType): String? {
            var path = generateThumbnail(context, fileId, type)
            if (path != null) return path

            when (type) {
                MediaFile.MediaType.IMAGE -> {
                    context.contentResolver.query(
                            MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI,
                            arrayOf(MediaStore.Images.Thumbnails.DATA),
                            "${MediaStore.Images.Thumbnails.IMAGE_ID} = $fileId"
                                    + " AND ${MediaStore.Images.Thumbnails.KIND} = ${MediaStore.Images.Thumbnails.MINI_KIND}",
                            null,
                            null)?.use { cursor ->
                        if (cursor.count > 0) {
                            cursor.moveToFirst()
                            path = cursor.getString(0)
                        }
                    }
                }
                MediaFile.MediaType.VIDEO -> {
                    context.contentResolver.query(
                            MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI,
                            arrayOf(MediaStore.Video.Thumbnails.DATA),
                            "${MediaStore.Video.Thumbnails.VIDEO_ID} = $fileId AND "
                                    + "${MediaStore.Video.Thumbnails.KIND} = ${MediaStore.Video.Thumbnails.MINI_KIND}",
                            null,
                            null)?.use { cursor ->
                        if (cursor.count > 0) {
                            cursor.moveToFirst()
                            path = cursor.getString(0)
                        }
                    }
                }
            }
            return path
        }

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        @Throws(Exception::class)
        private fun generateThumbnail(context: Context, fileId: Long, type: MediaFile.MediaType): String? {
            val bitmap = when (type) {
                MediaFile.MediaType.IMAGE -> {
                    MediaStore.Images.Thumbnails.getThumbnail(
                            context.contentResolver, fileId,
                            MediaStore.Images.Thumbnails.MINI_KIND, null)
                }
                MediaFile.MediaType.VIDEO -> {
                    MediaStore.Video.Thumbnails.getThumbnail(
                            context.contentResolver, fileId,
                            MediaStore.Video.Thumbnails.MINI_KIND, null)

                }
            } ?: throw Exception("Unable to generate thumbnail")

            bitmap.recycle()
            return null
        }

        private fun updateThumbnailMediaStore(context: Context, fileId: Long, type: MediaFile.MediaType, outputFile: File) {
            when (type) {
                MediaFile.MediaType.IMAGE -> {
                    val values = ContentValues()
                    values.put(MediaStore.Images.Thumbnails.DATA, outputFile.path)
                    try {
                        values.put(MediaStore.Images.Thumbnails.IMAGE_ID, fileId)
                        values.put(MediaStore.Images.Thumbnails.KIND, MediaStore.Images.Thumbnails.MINI_KIND)
                        context.contentResolver.insert(MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI, values)
                    } catch (e: Exception) {
                        context.contentResolver.update(MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI, values,
                                "${MediaStore.Images.Thumbnails.IMAGE_ID} = $fileId AND " +
                                        "${MediaStore.Images.Thumbnails.KIND} = ${MediaStore.Images.Thumbnails.MINI_KIND}",
                                null)
                    }
                }
                MediaFile.MediaType.VIDEO -> {
                    val values = ContentValues()
                    values.put(MediaStore.Video.Thumbnails.DATA, outputFile.path)
                    try {
                        values.put(MediaStore.Video.Thumbnails.VIDEO_ID, fileId)
                        values.put(MediaStore.Video.Thumbnails.KIND, MediaStore.Video.Thumbnails.MINI_KIND)
                        context.contentResolver.insert(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI, values)
                    } catch (e: Exception) {
                        context.contentResolver.update(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI, values,
                                "${MediaStore.Video.Thumbnails.VIDEO_ID} = $fileId AND " +
                                        "${MediaStore.Video.Thumbnails.KIND} = ${MediaStore.Video.Thumbnails.MINI_KIND}",
                                null
                        )
                    }
                }

            }

        }

    }
}