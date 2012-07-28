//
//  VideoUtil.h
//  rgbpicker
//
//  Created by Vijay Selvaraj on 7/28/12.
//  Copyright (c) 2012 Vijay Selvaraj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoUtil : NSObject {
    
}


-(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;




@end
