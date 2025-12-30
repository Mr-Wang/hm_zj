/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
import { CompressorResponseCode, CompressQuality, VideoCompressor } from '@ohos/videocompressor';
import { hilog } from '@kit.PerformanceAnalysisKit';
import fs from '@ohos.file.fs';
import { FileProcessResult } from '../model/DataModel';
import { media } from '@kit.MediaKit';

const DOMAIN_ID: number = 0x0000;
const TAG: string = 'CompressUtil';

export class CompressUtil {
  /**
   * 对传入的视频按照指定的质量条件进行压缩
   * @param context 上下文
   * @param quality 质量标识
   * @param qualityTag 质量标识文字
   * @param videoPath 待压缩视频路径
   * @returns
   */
  static async compressVideo(context: Context, quality: CompressQuality, qualityTag: string, videoPath: string) {
    if (!context) {
      return Promise.resolve(undefined);
    }
    try {
      let videoCompressor = new VideoCompressor();
      let data = await videoCompressor.compressVideo(context, videoPath, quality);
      if (data.code === CompressorResponseCode.SUCCESS) {
        hilog.info(DOMAIN_ID, TAG,
          'videoCompressor %{public}s message: %{public}s --outputPath:%{public}s', qualityTag, data.message, data.outputPath);
        // 获取存在应用沙箱路径下的 压缩后的视频文件
        let buffer = CompressUtil.getVideo(data.outputPath);
        let compressSize = fs.statSync(data.outputPath).size;
        let result = { buffer: buffer, filePath: data.outputPath, fileSize: compressSize } as FileProcessResult;
        hilog.info(DOMAIN_ID, TAG, 'The buffer: %{public}s', JSON.stringify(buffer));
        return Promise.resolve(result)
      } else {
        hilog.info(DOMAIN_ID, TAG,
          'videoCompressor %{public}s code:%{public}d --error message:%{public}s', qualityTag, data.code, data.message);
        return Promise.resolve(undefined);
      }
    } catch (err) {
      hilog.info(DOMAIN_ID, TAG, 'videoCompressor %{public}s get error message: %{public}s', qualityTag, err.message);
      return Promise.resolve(undefined);
    }
  }

  /**
   * 获取指定文件的ArrayBuffer
   * @param outputPath
   * @returns
   */
  static getVideo(outputPath: string): ArrayBuffer {
    let file: fs.File | undefined = undefined;
    let arrayBuffer = new ArrayBuffer(0);
    try {
      file = fs.openSync(outputPath, fs.OpenMode.READ_WRITE);
      let videoSize = fs.statSync(file.fd).size;
      arrayBuffer = new ArrayBuffer(videoSize);
      fs.readSync(file.fd, arrayBuffer);
    } catch (err) {
      hilog.info(DOMAIN_ID, TAG, 'videoCompressor get file buffer error message: %{public}s', err.message);
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
    return arrayBuffer;
  }



  /**
   * 获取视频的缩略图
   * @param videoPath
   * @returns
   */
  static async getVideoThumbnails(videoPath: string) {
    let pixelMap: PixelMap | undefined = undefined;
    let videoFile: fs.File | undefined = undefined;
    try {
      // 创建AVImageGenerator对象。
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      videoFile = fs.openSync(videoPath, fs.OpenMode.READ_ONLY);
      // 设置fdSrc。
      avImageGenerator.fdSrc = { fd: videoFile.fd }

      // 初始化入参。
      let timeUs = 0;
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      let param: media.PixelMapParams = {};

      // 获取缩略图（promise模式）。
      pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);

      // 释放资源（promise模式）。
      avImageGenerator.release();
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Get video thumbnails to albums error: %{public}d %{public}s`, e.code, e.message);
    } finally {
      if (videoFile) {
        fs.closeSync(videoFile);
      }
    }
    return pixelMap;
  }
}


