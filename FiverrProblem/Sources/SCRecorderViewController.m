//
//  VRViewController.m
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 SCorsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "SCVideoPlayerViewController.h"
#import "SCImageDisplayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}

@property (strong, nonatomic) SCRecorderToolsView *focusView;

@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController

#pragma mark - UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0



#endif

#pragma mark - Left cycle

- (void)dealloc {
    _recorder.previewView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capturePhotoButton.alpha = 0.0;
    
    _abool = false;
    _abool1 = true;
    _cameraOn = false;
    
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    //    _recorder.maxRecordDuration = CMTimeMake(10, 1);
    //    _recorder.fastRecordMethodEnabled = YES;
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO; //YES causes bad orientation for video from camera roll
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    
    
    self.loadingView.hidden = YES;
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:_light.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.focusView addGestureRecognizer:singleFingerTap];
    singleFingerTap.numberOfTapsRequired = 2;
    
    self.focusView.recorder = _recorder;
    [_light addSubview:self.focusView];
    [self.focusView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)]];
    
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"Circles"];
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) handleReverseCameraTapped:(id)sender {
    [_recorder switchCaptureDevices];
}

-(void)move:(UIPanGestureRecognizer*)sender {
    
    _maxZoomFactor = 25;
    _minZoomFactor = 1;
    
    NSLog(@"hemi1");
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _startPoint = [sender locationInView:self.flass];
        _zoomAtStart = _recorder.videoZoomFactor;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
        _newPoint = [sender locationInView:self.previewView];
        
        _scale = _startPoint.y / _newPoint.y;
        
        _newZoom = _scale * _zoomAtStart;
        
        if ( _newZoom > _maxZoomFactor ) {
            _newZoom = _maxZoomFactor;
        } else if ( _newZoom < _minZoomFactor ) {
            _newZoom = _minZoomFactor;
        }
        NSLog(@"hemi");
        _recorder.videoZoomFactor = _newZoom;
        
    } else {
        _newPoint = [sender locationInView:self.previewView];
        
        _scale = _startPoint.y / _newPoint.y;
        
        _newZoom = _scale * _zoomAtStart ;
        
        if ( _newZoom > _maxZoomFactor ) {
            _newZoom = _maxZoomFactor;
        } else if ( _newZoom < _minZoomFactor ) {
            _newZoom = _minZoomFactor;
        }
        NSLog(@"hemi");
        _recorder.videoZoomFactor = _newZoom;
        
        
    }
    
    
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    
    [self performSegueWithIdentifier:@"Video" sender:self];
    
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    // abool = camera flash indicated on
    
    
    // abool1 = camera is facing back
    
    // cameraOn = if camera is currently recording
    
    
    
    
    if (_abool == true){
        
        if (_abool1 == true) {
            
            if (_cameraOn == true) {
                
                
                [self LightBack];
                [_recorder switchCaptureDevices];
                
            } else {
                
                [self ResetBack];
                [_recorder switchCaptureDevices];
            }
            
        } else {
            
            if (_cameraOn == true) {
                
                [self LightFront];
                [_recorder switchCaptureDevices];
            } else {
                
                [self ResetFront];
                [_recorder switchCaptureDevices];
            }
        }
        
        
    } else {
        
        [self ResetBack];
        [self ResetFront];
        
        
        
        [_recorder switchCaptureDevices];
        
    }
    
    if (_abool1 == false) {
        _abool1 = true;
        [self DoIt];
    } else {
        _abool1 = false;
        [self DoIt];
    }
    
    
    
}


-(void)DoIt {
    
    // abool = camera flash indicated on
    
    // abool1 = camera is facing back
    
    // cameraOn = if camera is currently recording
    
    
    [self ResetBack];
    [self ResetFront];
    
    if (_abool == true){
        
        if (_abool1 == true) {
            
            if (_cameraOn == true) {
                
                
                [self LightBack];
                
                
            } else {
                
                [self ResetBack];
            }
            
        } else {
            
            if (_cameraOn == true) {
                
                [self LightFront];
                
            } else {
                
                [self ResetFront];
                
            }
        }
        
        
    } else {
        
        [self ResetBack];
        [self ResetFront];
        
    }
    
    
}


-(void)LightFront {
    _light.alpha = 0.5;
    _light.backgroundColor = UIColor.whiteColor;
    
}

-(void)LightBack {
    _recorder.flashMode = SCFlashModeLight;
}

-(void)ResetFront {
    _light.alpha = 1;
    _light.backgroundColor = UIColor.clearColor;
}
-(void)ResetBack {
    
    _recorder.flashMode = SCFlashModeOff;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerViewController class]]) {
        SCVideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.recordSession = _recordSession;
    } else if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
        imageDisplayer.photo = _photo;
        _photo = nil;
    } else if ([segue.destinationViewController isKindOfClass:[SCSessionListViewController class]]) {
        SCSessionListViewController *sessionListVC = segue.destinationViewController;
        
        sessionListVC.recorder = _recorder;
    }
}

- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:url info:nil];
    
    [_recorder.session addSegment:segment];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:segment];
    
    [self showVideo];
}
- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        
        if (CMTimeGetSeconds(_recorder.session.duration) > 0) {
            
            [self saveAndShowSession:_recorder.session];
        }
    }];
}
- (IBAction)oks:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
    
}
- (IBAction)ob:(id)sender {
    
    [self performSegueWithIdentifier:@"Video" sender:self];
    
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    if (CMTimeGetSeconds(_recorder.session.duration) > 0) {
        
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
        
        _recordSession = recordSession;
        
    }
    [self showVideo];
}

- (void)handleRetakeButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
        [UIView animateWithDuration:0.3
                         animations:^{
                             _rbut.alpha = 1;
                             _lbut.alpha = 1;
                             _rbut2.alpha = 0;
                             _lbut2.alpha = 0;
                             _l1.alpha = 1;
                             _r1.alpha = 0;
                             _r2.alpha = 1;
                             _l2.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    [self prepareSession];
}

- (IBAction)switchCameraMode:(id)sender {
    
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
            self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = kVideoPreset;
            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
}

- (IBAction)switchflasher:(id)sender {
    
    // Turn Off
    
    if (_abool == true) {
        
        _light.alpha = 1;
        _light.backgroundColor = UIColor.clearColor;
        
        _flass.image = [UIImage imageNamed:@"Icon-1"];
        _recorder.flashMode = SCFlashModeOff;
        _flashModeButton.alpha = 1;
        _ok.alpha = 0;
        _abool = false;
    }
    
}

- (IBAction)switchFlash:(id)sender {
    
    // Turn On
    
    // abool = Flash On
    _abool = true;
    if (_abool == true) {
        
        _light.alpha = 1;
        _light.backgroundColor = UIColor.clearColor;
        _flass.image = [UIImage imageNamed:@"Bolt"];
        _recorder.flashMode = SCFlashModeOff;
        _flashModeButton.alpha = 0;
        _ok.alpha = 1;
        _abool = true;
    }
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    if (CMTimeGetSeconds(_recorder.session.duration) > 0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _rbut.alpha = 0;
                             _lbut.alpha = 0;
                             _rbut2.alpha = 1;
                             _lbut2.alpha = 1;
                             _l1.alpha = 0;
                             _r1.alpha = 1;
                             _r2.alpha = 0;
                             _l2.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             
                         }];}
    
    [self updateTimeRecordedLabel];
    [self updateGhostImage];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    [self updateGhostImage];
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
        
        
    }
    
    
    
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.2f sec", CMTimeGetSeconds(currentTime)];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        _rbut.alpha = 0;
        _lbut.alpha = 0;
        _rbut2.alpha = 0;
        _lbut2.alpha = 0;
        
        
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _l1.alpha = 0;
                             _r1.alpha = 0;
                             _r2.alpha = 0;
                             _l2.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        [_recorder record];
        
        _cameraOn = true;
        printf("falllss");
        
        [self DoIt];
        [UIView animateWithDuration:0.3
                         animations:^{
                             _yeppa.transform = CGAffineTransformMakeScale(1.4, 1.4);
                             _redder.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        _ghostImageView.hidden = YES;
        
        
        
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        
        
        [_recorder pause];
        _cameraOn = false;
        _light.alpha = 1;
        _light.backgroundColor = UIColor.clearColor;
        _recorder.flashMode = SCFlashModeOff;
        printf("falll");
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _yeppa.transform = CGAffineTransformMakeScale(1, 1);
                             _redder.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                         }];
        if (_recorder.session.segments.count >= 0) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _rbut.alpha = 0;
                                 _lbut.alpha = 0;
                                 _rbut2.alpha = 1;
                                 _lbut2.alpha = 1;
                                 _l1.alpha = 0;
                                 _r1.alpha = 1;
                                 _r2.alpha = 0;
                                 _l2.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        } else {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _rbut.alpha = 1;
                                 _lbut.alpha = 1;
                                 _rbut2.alpha = 0;
                                 _lbut2.alpha = 0;
                                 _l1.alpha = 1;
                                 _r1.alpha = 0;
                                 _r2.alpha = 1;
                                 _l2.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        
    }
    
}

- (IBAction)capturePhoto:(id)sender {
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            [self showPhoto:image];
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
        }
    }];
}

- (void)updateGhostImage {
    UIImage *image = nil;
    
    if (_ghostModeButton.selected) {
        if (_recorder.session.segments.count > 0) {
            SCRecordSessionSegment *segment = [_recorder.session.segments lastObject];
            image = segment.lastImage;
        }
    }
    
    
    _ghostImageView.image = image;
    //    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    _ghostImageView.hidden = !_ghostModeButton.selected;
}



- (IBAction)switchGhostMode:(id)sender {
    _ghostModeButton.selected = !_ghostModeButton.selected;
    _ghostImageView.hidden = !_ghostModeButton.selected;
    
    [self updateGhostImage];
}
- (IBAction)toolsButtonTapped:(UIButton *)sender {
    CGRect toolsFrame = self.toolsContainerView.frame;
    CGRect openToolsButtonFrame = self.openToolsButton.frame;
    
    if (toolsFrame.origin.y < 0) {
        sender.selected = YES;
        toolsFrame.origin.y = 0;
        openToolsButtonFrame.origin.y = toolsFrame.size.height + 15;
    } else {
        sender.selected = NO;
        toolsFrame.origin.y = -toolsFrame.size.height;
        openToolsButtonFrame.origin.y = 15;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.toolsContainerView.frame = toolsFrame;
        self.openToolsButton.frame = openToolsButtonFrame;
    }];
}
- (IBAction)closeCameraTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
