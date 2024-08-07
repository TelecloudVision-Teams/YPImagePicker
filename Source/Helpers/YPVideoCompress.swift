//
//  YPVideoCompress.swift
//  YPImagePicker
//
//  Created by Ali on 07/08/2024.
//  Copyright © 2024 Yummypets. All rights reserved.
//

import Foundation

struct YPVideoCompress
{
    var compression:Compression?
    mutating func compress(input:URL, completionHandler:@escaping(Result<URL,Error>)->Void, progress:@escaping(Double)->Void)
    {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingUniquePathComponent(pathExtension: YPConfig.video.fileType.fileExtension)
        try? FileManager.default.removeFileIfNecessary(at: fileURL)
        
        let videoCompressor = VideoCompressor()
        let config = VideoCompressor.Video.Configuration.init(quality: VideoQuality.medium, videoBitrateInMbps:1)
        let video = VideoCompressor.Video.init(source: input, destination: fileURL, configuration: config)
        compression = videoCompressor.compressVideo(videos: [video],
                                                        progressQueue: .main,
                                                        progressHandler: { currentProgress in
            DispatchQueue.main.async {
                progress(currentProgress.fractionCompleted)
            }},
                                                        completion: { result in
            switch result {
                
            case .onSuccess(_, let path):
                DispatchQueue.main.async
                {
                    completionHandler(.success(path))
                }
                
            case .onStart:
                print("Compression Started")
                
            case .onFailure(_, let error):
                print("Compression error: \(error)")
                DispatchQueue.main.async
                {
                    completionHandler(.failure(error))
                }
                
            case .onCancelled:
                print("Compression Cancelled")
            }
        })
    }
    func cancel()
    {
        compression?.cancel = true
    }

}
