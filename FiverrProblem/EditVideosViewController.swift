//
//  EditVideosViewController.swift
//  FiverrProblem
//
//  Created by Moin Janjua on 29/07/2019.
//  Copyright © 2019 Joshua Mirecki. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import AVKit
import MobileCoreServices
import CoreMedia


class EditVideosViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var VideoView: UIImageView!
    @IBOutlet weak var SliderView: UIView!
    @IBOutlet weak var StartTextView: UITextField!
    @IBOutlet weak var EndTextField: UITextField!
    @IBOutlet weak var CropBTN: UIButton!
    
    var thumbnails = [UIImage]()
    var videoClips:[NSURL] = [NSURL]()
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self

    }
    
    
    
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIBarButtonItem) {

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let urlval = info[UIImagePickerControllerMediaURL] as? NSURL
        print(videoURL as Any)
        imagePickerController.dismiss(animated: true, completion: nil)
        do {
            let asset = AVURLAsset(url: urlval! as URL , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            VideoView.image = thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        let minDuration : CMTime = CMTimeMake(0, 1)
        let maxDuration : CMTime = CMTimeMake(5, 1)
        VideoUltilities.init().cropVideo(sourceURL: urlval! as URL, startTime: 0.5, endTime: 1.10, completion: { (url) in
            self.videoURL = url as NSURL
            
            let player = AVPlayer(url: url as URL)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        })
       
    }
    
    
    @IBAction func TrimVideosBtn(_ sender: Any) {


        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.mediaTypes = ["public.video", "public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
 
}
