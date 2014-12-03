//
//  ScannerViewController.m
//  moodstocks
//
//  Created by Shaohuan on 12/1/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import "ScannerViewController.h"

@interface ScannerViewController () <MSAutoScannerSessionDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoPreview;
@end

static int kMSResultTypes = MSResultTypeImage  |
MSResultTypeQRCode |
MSResultTypeEAN13;

@implementation ScannerViewController {
    MSAutoScannerSession *_scannerSession;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scannerSession.delegate = self;
    _scannerSession = [[MSAutoScannerSession alloc] initWithScanner:_scanner];
    _scannerSession.resultTypes = kMSResultTypes;
    CALayer *videoPreviewLayer = [self.videoPreview layer];
    [videoPreviewLayer setMasksToBounds:YES];
    
    CALayer *captureLayer = [_scannerSession captureLayer];
    [captureLayer setFrame:[self.videoPreview bounds]];
    
    [videoPreviewLayer insertSublayer:captureLayer
                                below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
    [_scannerSession startRunning];
}

- (void)session:(id)scannerSession didFindResult:(MSResult *)result
{
    // Delegate callback: implemented in a few steps
    NSString *title = [result type] == MSResultTypeImage ? @"Image" : @"Barcode";
    NSString *message = [NSString stringWithFormat:@"%@:\n%@", title, [result string]];
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet showInView:self.view];
}


- (void)updateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [_scannerSession setInterfaceOrientation:interfaceOrientation];
    
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *) [_scannerSession captureLayer];
    
    captureLayer.frame = self.view.bounds;
    
    // AVCapture orientation is the same as UIInterfaceOrientation
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

- (void)viewWillLayoutSubviews
{
    [self updateInterfaceOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self updateInterfaceOrientation:orientation];
}

// ScannerViewController.m

- (void)dealloc
{
    [_scannerSession stopRunning];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_scannerSession resumeProcessing];
}
@end
