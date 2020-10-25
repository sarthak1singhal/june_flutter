import 'dart:async';
import 'dart:io';

import 'package:flutter_uploader/flutter_uploader.dart';
 import 'package:path/path.dart';

class VideoUploader{
  static Map<String, UploadItem> _tasks = {};
  static FlutterUploader uploader = FlutterUploader();
  static StreamSubscription _progressSubscription;
  static StreamSubscription _resultSubscription;

  static Future uploadVideo({bool binary, File video, String url, Map<String, String> headers}) async {
     if (video != null) {

       _progressSubscription = uploader.progress.listen((progress) {
         final task = _tasks[progress.tag];
         print("progress: ${progress.progress} , tag: ${progress.tag}");
         if (task == null) return;
         if (task.isCompleted()) return;
            _tasks[progress.tag] =
               task.copyWith(progress: progress.progress, status: progress.status);
        });
       _resultSubscription = uploader.result.listen((result) {
         print("id: ${result.taskId}, status: ${result.status}, response: ${result.response}, statusCode: ${result.statusCode}, tag: ${result.tag}, headers: ${result.headers}");

         final task = _tasks[result.tag];
         if (task == null) return;

            _tasks[result.tag] = task.copyWith(status: result.status);
        }, onError: (ex, stacktrace) {
         print("exception: $ex");
         print("stacktrace: $stacktrace" ?? "no stacktrace");
         final exp = ex as UploadException;
         final task = _tasks[exp.tag];
         if (task == null) return;

            _tasks[exp.tag] = task.copyWith(status: exp.status);
        });
      final String savedDir = dirname(video.path);
      final String filename = basename(video.path);
      final tag = "video uploading";

      var fileItem = FileItem(
        filename: filename,
        savedDir: savedDir,
        fieldname: "file",
      );

      var taskId = binary
          ? await uploader.enqueueBinary(
        url: url,
        file: fileItem,
        headers: headers,
        method: UploadMethod.PUT,
        tag: tag,
        showNotification: true,
      )
          : await uploader.enqueue(
        url: url,
         files: [fileItem],
        headers: headers,

        method: UploadMethod.PUT,

        tag: tag,
        showNotification: true,
      );

      _tasks.putIfAbsent(
          tag,
              () => UploadItem(
            id: taskId,
            tag: tag,
            type: MediaType.Video,
            status: UploadTaskStatus.enqueued,
          ));
    }
  }


 static Future cancelUpload(String id) async {
    await uploader.cancel(taskId: id);
  }











}


class UploadItem {
  final String id;
  final String tag;
  final MediaType type;
  final int progress;
  final UploadTaskStatus status;

  UploadItem({
    this.id,
    this.tag,
    this.type,
    this.progress = 0,
    this.status = UploadTaskStatus.undefined,
  });

  UploadItem copyWith({UploadTaskStatus status, int progress}) =>
      UploadItem(
          id: this.id,
          tag: this.tag,
          type: this.type,
          status: status ?? this.status,
          progress: progress ?? this.progress);

  bool isCompleted() {

    if(this.status == UploadTaskStatus.complete )
      {

        print("COMMMMMMMMMMMMPPPPPPPPPPPLLLLLLLLLLEEEEEEEETTTTTTEEEEEEEEEEDDDDDDDDDD");
      }
 return   this.status == UploadTaskStatus.canceled ||
        this.status == UploadTaskStatus.complete ||
        this.status == UploadTaskStatus.failed;
  }
}
enum MediaType { Image, Video }