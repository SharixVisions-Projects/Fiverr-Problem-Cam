//
//  VideoUltilities.swift
//
//  Created by Le Ngoc Giang on 4/13/16.
//  Copyright © 2016 gianglengoc. All rights reserved.
//
import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import MobileCoreServices

class VideoUltilities: NSObject {
    
    
    
    
  
  static let sharedInstance = VideoUltilities()
    var videoClips:[NSURL] = [NSURL]()
  
  // MARK: Public methods
  
  
    
    
    
    
//
//    func cropVideo(url: NSURL, completion: @escaping (NSURL?, NSError?) -> Void) -> Void {
//
//    let outputURL = url
//
//    let fileManager = FileManager.default
//
//    let asset : AVURLAsset = AVURLAsset(url: outputURL as URL, options: nil)
//
//    if let clipVideoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video)[0] {
//
//      if clipVideoTrack.naturalSize.height == clipVideoTrack.naturalSize.width {
//        let stringURL = outputURL.absoluteString?.replacingOccurrences(of: "file://", with: "")
//        //let stringURL = outputURL.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "")
//        completion(NSURL(string: stringURL!), nil)
//        return
//      }
//
//      let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
//
//      videoComposition.frameDuration = CMTimeMake(1, 30)
//
//      let squareSize =  clipVideoTrack.naturalSize.height > clipVideoTrack.naturalSize.width ? clipVideoTrack.naturalSize.width : clipVideoTrack.naturalSize.height
//
//      videoComposition.renderSize = CGSize.init(width: squareSize, height: squareSize)
//
//      let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
//      instruction.timeRange = CMTimeRangeMake(kCMTimeZero,  CMTimeMakeWithSeconds(60, 30))
//
//      let transformer: AVMutableVideoCompositionLayerInstruction =
//        AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
//
//        let t1: CGAffineTransform = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2 )
//
//        let t2: CGAffineTransform = t1.rotated(by: CGFloat(Double.pi))  //CGAffineTransformRotate(t1, CGFloat(M_PI_2))
//
//      let finalTransform: CGAffineTransform = t2
//
//        transformer.setTransform(finalTransform, at: kCMTimeZero)
//      instruction.layerInstructions = [transformer]
//
//      videoComposition.instructions = [instruction]
//
//      let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "output2.mov")
//
//        let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
//
//        if(fileManager.fileExists(atPath: exportPath as String)) {
//
//            try! fileManager.removeItem(at: exportUrl as URL)
//      }
//
//      let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
//      exporter!.videoComposition = videoComposition
//        exporter!.outputFileType = AVFileType.mov
//        exporter!.outputURL = exportUrl as URL
//        exporter!.exportAsynchronously(completionHandler: { () -> Void in
//
//        print(CMTimeGetSeconds((exporter?.asset.duration)!))
//
//        switch exporter!.status {
//        case .completed :
//          let URL = NSURL(string: exportPath as String)
//          completion(URL, nil)
//
//        default:
//            print(exporter?.error ?? "")
//            completion(nil, exporter?.error as NSError?)
//        }
//      })
//    }
//  }

     func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil)
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
    
    func cropVideo(sourceURL1: NSURL, statTime:Float, endTime:Float)
    {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard let url = sourceURL1 as? NSURL else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(url: url as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = statTime
            let end = endTime
            
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                let name = hostent.init().h_name
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    //self.saveVideoTimeline(outputURL)
                case .failed:
                    print("failed \(exportSession.error ?? "" as! Error)")
                    
                case .cancelled:
                    print("cancelled \(exportSession.error ?? "default value" as! Error)")
                    
                default: break
                }
            }
        }
    }
    
    
    
    func trimVideov2(sourceURL: NSURL, startTime: CMTime, endTime: CMTime, withAudio: Bool, completion:@escaping (NSURL?, NSError?) -> Void) -> Void {
    
    let fileManager = FileManager.default
    
    let sourcePathURL = NSURL(fileURLWithPath: (sourceURL.absoluteString ?? ""))
    
   // let asset = AVURLAsset(url: sourcePathURL as URL)
        let asset: AVAsset = AVAsset(url: sourcePathURL as URL) as AVAsset
    
    let composition = AVMutableComposition()
    
    let videoCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
    let audioCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
    let assetAudioTrack = asset.tracks(withMediaType: AVMediaType.audio)[0]
    
    var accumulatedTime = kCMTimeZero
    
    let durationOfCurrentSlice = CMTimeSubtract(endTime, startTime)
    let timeRangeForCurrentSlice = CMTimeRangeMake(startTime, durationOfCurrentSlice)
    
    do {
        try videoCompTrack?.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
        try audioCompTrack?.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
    }
    catch let error {
      print("Error insert time range \(error)")
    }
    
    accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
    
    print("Trimv2 \(CMTimeGetSeconds(accumulatedTime))")
    
    let destinationPath = String(format: "%@%@", NSTemporaryDirectory(),"trim.mp4")
    let destinationPathURL = NSURL(fileURLWithPath: destinationPath)
    
    if fileManager.fileExists(atPath: destinationPath) {
      // remove if exists
      do {
        try fileManager.removeItem(at: destinationPathURL as URL)
      }
      catch let error {
        print("Could not remove file at path \(destinationPath) with error \(error)")
      }
    }
    
    let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    exportSession?.outputURL = destinationPathURL as URL
    exportSession?.outputFileType = AVFileType.mp4
    exportSession?.shouldOptimizeForNetworkUse = true
    
    exportSession?.exportAsynchronously(completionHandler: {
      switch exportSession!.status {
      case .completed :
        completion(NSURL(string: destinationPath),nil)
      default :
        print("Error export")
      }
    })
        
  }
    
 
    
    func removeAudioFromVideo(videoURL: NSURL, completion: @escaping (NSURL?, NSError?) -> Void) -> Void {

    let fileManager = FileManager.default

    let composition = AVMutableComposition()
    
    let sourceAsset = AVURLAsset(url: videoURL as URL)
    
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

    let sourceVideoTrack: AVAssetTrack = sourceAsset.tracks(withMediaType: AVMediaType.video)[0]
      
      let x = CMTimeRangeMake(kCMTimeZero, sourceAsset.duration)
      
    try! compositionVideoTrack?.insertTimeRange(x, of: sourceVideoTrack, at: kCMTimeZero)
      
      let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "removeAudio.mov")
      
    let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
      
    if(fileManager.fileExists(atPath: exportPath as String)) {
        
        try! fileManager.removeItem(at: exportUrl as URL)
      }
      
      let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    exporter!.outputURL = exportUrl as URL;
    exporter!.outputFileType = AVFileType.mov
      
    exporter?.exportAsynchronously(completionHandler: {
        
        DispatchQueue.main.async(execute: {
            completion(exporter?.outputURL as NSURL?, nil)
        })
          
        
        
      })
  }
  
  func generateThumbnailsForVideoWithURL(url: NSURL) -> NSMutableArray {
    
    let asset = AVURLAsset(url: NSURL(fileURLWithPath: url.absoluteString!) as URL)
    
    let assetDuration = CMTimeGetSeconds(asset.duration)
    
    let generate = AVAssetImageGenerator(asset: asset)
    
    let devices = AVCaptureDevice.devices(for: AVMediaType.video) as! [AVCaptureDevice]
    
    let captureDevice: AVCaptureDevice = devices.first!
    
    generate.appliesPreferredTrackTransform = true
    
    let timescale = captureDevice.activeVideoMaxFrameDuration.timescale
    
    let thumbnailArray = NSMutableArray()
    
    for frameNumber in 0...2 {
      
      let time = CMTime(value: Int64(frameNumber * Int(assetDuration)), timescale: timescale)
      
      do {
       
        let imgRef = try generate.copyCGImage(at: time, actualTime: nil)
        
        let image = UIImage(cgImage: imgRef)
        
        thumbnailArray.add(image)
      }
      catch let e {
        print("generate image error \(e)")
      } 
    }
    return thumbnailArray
  }
  
    func mergeAudioToVideo(souceAudioPath: String, souceVideoPath: String, completion:@escaping (NSURL?, NSError?) -> Void) -> Void {
    
    let fileManager = FileManager.default
    
    let composition = AVMutableComposition()
    
    let videoAsset = AVURLAsset(url: NSURL(fileURLWithPath: souceVideoPath) as URL)
    
    let audioAsset = AVURLAsset(url: NSURL(fileURLWithPath: souceAudioPath) as URL)
    
    let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try! audioTrack!.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: kCMTimeZero)
    
    let composedTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try! composedTrack!.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaType.video)[0], at: kCMTimeZero)
    
    let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "mergeVideo.mov")
    
    let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
    
    if(fileManager.fileExists(atPath: exportPath as String)) {
      
        try! fileManager.removeItem(at: exportUrl as URL)
    }
    
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    
    exporter!.outputURL = exportUrl as URL
    
    exporter!.outputFileType = AVFileType.mov
    
    exporter?.exportAsynchronously(completionHandler: {
    
        DispatchQueue.main.async(execute: {
            let stringURL = exportUrl.absoluteString?.replacingOccurrences(of: "file://", with: "")
            
            let URL = NSURL(string: stringURL!)
            
            completion(URL, nil)
        })
    })
  }
  
  func removeVideoWithPath(videoPath: String) -> Bool {
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: videoPath) {
      do {
        try fileManager.removeItem(at: NSURL(string: videoPath)! as URL)
        return true
      }
      catch let error {
        print("Could not remove video with path \(videoPath) error \(error)")
      }
    }
    return false
  }
  
  func getDurationFromFilePath(sourcePath: String) -> Float64 {
    
    let asset = AVURLAsset(url: NSURL(fileURLWithPath: sourcePath) as URL)
    
    let fileDuration = asset.duration
    
    return CMTimeGetSeconds(fileDuration)
    
  }
  
}
