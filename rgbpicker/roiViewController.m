//
//  roiViewController.m
//  rgbpicker
//
//  Created by Vijay Selvaraj on 7/27/12.
//  Copyright (c) 2012 Vijay Selvaraj. All rights reserved.
//

#import "roiViewController.h"

@interface roiViewController ()

@end

@implementation roiViewController
@synthesize uiView;
@synthesize captureSession;
@synthesize bottomBar;
@synthesize imgSample;
@synthesize headerView;
@synthesize colorPallet;
@synthesize rValue;
@synthesize gValue;
@synthesize bValue;
@synthesize hexValue;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Start the Video Capture session
    [self setupCaptureSession];
    
    imgUtil = [[ImageUtil alloc] init];

    UIImage *bottomBarImg = [UIImage imageNamed:@"bottombar.png"];
    [bottomBar setImage:bottomBarImg];

    
    [self.view bringSubviewToFront:headerView];
    [self.view bringSubviewToFront:bottomBar];
    [self.view bringSubviewToFront:colorPallet];
    
 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}




-(IBAction)buttonPressed:(id)sender {
    SystemSoundID *sound1;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"waterdrop"
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(soundURL), &sound1);    
    AudioServicesPlaySystemSound(sound1);
}


-(void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    //Find the video device
    AVCaptureDevice * capturedevice = [AVCaptureDevice
                                       defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
           /* if ([device position] == AVCaptureDevicePositionFront) {
                capturedevice = device;
                break;
            }*/

            if ([device position] == AVCaptureDevicePositionBack) {
                capturedevice = device;
                break;
            }
        }
    }
    
    //Set the media input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:capturedevice
                                                                        error:&error];
    
    if(!input)
    {
        NSLog(@"PANIC: no media input");
    }
    //Add video input
    [session addInput:input];
    
    //Set the video output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
    [session startRunning];
    self.captureSession=session;
    [self startPreview:session];    
}

-(void)startPreview:(AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    CGRect bounds = uiView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.bounds = bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [uiView.layer addSublayer:previewLayer];
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"captureOutput: didOutputSampleBufferFromConnection");
    
    
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
       
    // I had to do this so that the processing does not happen from the main thread. 
    dispatch_async(dispatch_get_main_queue(), ^{
        
        struct CGImage *img = [imgUtil CGImageRotatedByAngle:[image CGImage] angle:-90.0];
        
        int img_width = CGImageGetWidth(img);
        int img_height = CGImageGetHeight(img);
        int view_width = imgSample.bounds.size.width;
        int view_height = imgSample.bounds.size.height;
        

        
        CGRect croppedSection = CGRectMake((img_width/2)-view_width/2, (img_height/2)-view_height/2, view_width/2, view_height/2);
        CGImageRef imageRef = CGImageCreateWithImageInRect(img, croppedSection);
        
        [imgSample setImage:[UIImage imageWithCGImage:imageRef]];
    

        UIColor *color = [imgUtil getPixelColorAtLocation:imageRef:CGPointMake(3,3)];
        [colorPallet setBackgroundColor:color];
        [colorPallet setOpaque:FALSE];

        CGFloat* components = CGColorGetComponents([color CGColor]);
        
        [rValue setText:[NSString stringWithFormat:@"R:%i", (int)(components[0]*255.0f)]];
        [gValue setText:[NSString stringWithFormat:@"G:%i", (int)(components[1]*255.0f)]];
        [bValue setText:[NSString stringWithFormat:@"B:%i", (int)(components[2]*255.0f)]];


        NSString *hexVal = [imgUtil UIColorToHexString:color];

        [hexValue setText:[NSString stringWithFormat:@"HEX #: %s ", [hexVal UTF8String]]];


        CGImageRelease(imageRef);
        CGImageRelease(img);
                
                
        [self.view bringSubviewToFront:imgSample];
        [self.view bringSubviewToFront:colorPallet];

    });        
    [self.view setNeedsDisplay];
}



-(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    NSLog(@"imageFromSampleBuffer: called");
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little| kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    
    CGImageRelease(quartzImage);
    
    return (image);    
}


@end
