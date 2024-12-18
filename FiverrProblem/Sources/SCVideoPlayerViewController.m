//
//  SCVideoPlayerViewController.m
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 8/30/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import "SCVideoPlayerViewController.h"
#import "FiverrProblem-Swift.h"
#import "SCEditVideoViewController.h"
#import "SCRecorderViewController.h"
#import "SCWatermarkOverlayView.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface SCVideoPlayerViewController ()

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

@end

@implementation SCVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc {
    [self.filterSwitcherView removeObserver:self forKeyPath:@"selectedFilter"];
    self.filterSwitcherView = nil;
    [_player pause];
    _player = nil;
    [self cancelSaveToCameraRoll];
}

- (SCFilter *)createAnimatedFilter {
    SCFilter *animatedFilter = [SCFilter emptyFilter];
    animatedFilter.name = @"Wasted";
    
    SCFilter *gaussian = [SCFilter filterWithCIFilterName:@"CIGaussianBlur"];
    SCFilter *blackAndWhite = [SCFilter filterWithCIFilterName:@"CIColorControls"];
    
    [animatedFilter addSubFilter:gaussian];
    [animatedFilter addSubFilter:blackAndWhite];
    
    double duration = 0.5;
    double currentTime = 0;
    BOOL isAscending = YES;
    
    Float64 assetDuration = CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration);
    
    while (currentTime < assetDuration) {
        if (isAscending) {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@1 endValue:@0 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@0 endValue:@10 startTime:currentTime duration:duration];
        } else {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@0 endValue:@1 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@10 endValue:@0 startTime:currentTime duration:duration];
        }
        
        currentTime += duration;
        isAscending = !isAscending;
    }
    
    return animatedFilter;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.exportView.clipsToBounds = YES;
    self.exportView.layer.cornerRadius = 20;
    
    
    
    _player = [SCPlayer player];
    
    if ([[NSProcessInfo processInfo] activeProcessorCount] > 1) {
        
        
        SCFilter *emptyFilter = [SCFilter emptyFilter];
        emptyFilter.name = @"Normal";
        
        self.filterSwitcherView.filters = @[
                                            emptyFilter,
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                            // Adding a filter created using CoreImageShop
                                            
                                            [self createAnimatedFilter]
                                            ];
        _player.SCImageView = self.filterSwitcherView;
        [self.filterSwitcherView addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
        
        playerView.frame = self.filterSwitcherView.frame;
        playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
        [self.filterSwitcherView.superview insertSubview:playerView aboveSubview:self.filterSwitcherView];
        [self.filterSwitcherView removeFromSuperview];
    }
    
    _player.loopEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.filterSwitcherView) {
        self.filterNameLabel.hidden = NO;
        self.filterNameLabel.text = self.filterSwitcherView.selectedFilter.name;
        self.filterNameLabel.alpha = 0;
        self.filterNameLabel1.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.filterNameLabel.alpha = 1;
            self.filterNameLabel1.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.filterNameLabel.alpha = 0;
                    self.filterNameLabel1.alpha = 0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
}


- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        CGRect frame =  self.progressView.frame;
        frame.size.width = self.progressView.superview.frame.size.width * progress;
        self.progressView.frame = frame;
    });
}

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)cancelTapped:(id)sender {
    [self cancelSaveToCameraRoll];
}

- (void)_addActionToAlertController:(UIAlertController *)alertController forType:(SCContextType)contextType withName:(NSString *)name {
    if ([SCContext supportsType:contextType]) {
        UIAlertActionStyle style = (self.filterSwitcherView.contextType != contextType ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive);
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:style handler:^(UIAlertAction * _Nonnull action) {
            self.filterSwitcherView.contextType = contextType;
        }];
        [alertController addAction:action];
    }
}

- (IBAction)changeRenderingModeTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change video rendering mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCEditVideoViewController class]]) {
        SCEditVideoViewController *editVideo = segue.destinationViewController;
        printf("hellos");
        editVideo.recordSession = self.recordSession;
    }
    
}

- (void)saveToCameraRoll {
    
    SCFilter *currentFilter = [self.filterSwitcherView.selectedFilter copy];
    [_player pause];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 60;
    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    
    self.exportSession = exportSession;
    
    self.exportView.hidden = NO;
    self.exportView.alpha = 0;
    
    CGRect frame =  self.progressView.frame;
    frame.size.width = 0;
    
    self.progressView.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.exportView.alpha = 1;
    }];
    
    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        if (strongSelf != nil) {
            [strongSelf.player play];
            strongSelf.exportSession = nil;
            
            [UIView animateWithDuration:0.3 animations:^{
                strongSelf.exportView.alpha = 0;
            }];
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                if (error == nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (BOOL)startMediaBrowser {
    //Validations
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:url info:nil];
    
    [_recordSession addSegment:segment];
}



@end
