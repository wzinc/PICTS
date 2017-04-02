#import <Foundation/Foundation.h>
#import "Utilities.h"
#import <UIKit/UIKit.h>

@interface CVUtils : NSObject

+(UIImage*)loadImage:(NSString*)fileName layers:(uint8_t)layers;
+(UIImage*)loadImage:(NSString*)fileName withExtraLayers:(NSString*)extraLayersFileName layers:(uint8_t)layers;

+(UIImage*)UIImageFromCVMat:(cv::Mat)cvMat;

@end
