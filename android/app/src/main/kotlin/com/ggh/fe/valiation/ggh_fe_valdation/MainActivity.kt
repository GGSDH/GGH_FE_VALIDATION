package com.ggh.fe.valiation.ggh_fe_valdation

import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ggh.fe.valiation/images"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "getAllImages") {
//                if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
//                    result.success(getAllImages())
//                } else {
//                    ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), 1)
//                    result.success(null)
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
    }

//    private fun getAllImages(): List<String> {
//        val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
//        val projection = arrayOf(MediaStore.Images.Media._ID, MediaStore.Images.Media.DISPLAY_NAME)
//        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
//        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, sortOrder)
//        val imagePaths = mutableListOf<String>()
//        cursor?.use {
//            val idColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
//            while (it.moveToNext()) {
//                val id = it.getLong(idColumn)
//                val contentUri: Uri = ContentUris.withAppendedId(uri, id)
//                imagePaths.add(contentUri.toString())
//            }
//        }
//        return imagePaths
//    }
}
