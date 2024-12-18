//
//  VRViewController.h
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate, UIImagePickerControllerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ok;
@property (strong, nonatomic) SCRecordSession *recordSession;

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redder;
@property (weak, nonatomic) IBOutlet UIImageView *capture;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIView *dissa;
@property (weak, nonatomic) IBOutlet UIImageView *rere;
@property (weak, nonatomic) IBOutlet UIImageView *reccc;
@property (weak, nonatomic) IBOutlet UIView *coll;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;

@property (assign) BOOL shouldAllowPan;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *now;

@property (weak, nonatomic) IBOutlet UIView *yeppa;
@property (weak, nonatomic) IBOutlet UIImageView *l1;
@property (weak, nonatomic) IBOutlet UIImageView *r2;
@property (weak, nonatomic) IBOutlet UIImageView *l2;
@property (weak, nonatomic) IBOutlet UIButton *lbut;
@property (weak, nonatomic) IBOutlet UIButton *rbut;
@property (weak, nonatomic) IBOutlet UIButton *rbut2;
@property (weak, nonatomic) IBOutlet UIButton *lbut2;

@property (weak, nonatomic) IBOutlet UIButton *recordB;
@property (weak, nonatomic) IBOutlet UIImageView *r1;
@property (assign) BOOL abool;
@property (assign) BOOL abool1;
@property (assign) BOOL cameraOn;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *paner;
@property (nonatomic) CGFloat myVar;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGFloat zoomAtStart;
@property (nonatomic) CGFloat maxZoomFactor;
@property (nonatomic) CGFloat minZoomFactor;
@property (nonatomic) CGPoint newPoint;
@property (nonatomic) CGFloat newP;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat newZoom;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *gridders;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *rollers;
@property (weak, nonatomic) IBOutlet UIImageView *gr1;
@property (weak, nonatomic) IBOutlet UIImageView *gr2;


@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
@property (weak, nonatomic) IBOutlet UIView *toolsContainerView;

@property (weak, nonatomic) IBOutlet UIButton *openToolsButton;

@property (weak, nonatomic) IBOutlet UIImageView *flass;
@property (weak, nonatomic) IBOutlet UIView *light;

- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)capturePhoto:(id)sender;
- (IBAction)switchGhostMode:(id)sender;

@end


