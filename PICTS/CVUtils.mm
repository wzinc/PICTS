#import "CVUtils.h"
#import "Utilities.h"

@implementation CVUtils

+(UIImage*)loadImage:(NSString*)fileName layers:(uint8_t)layers
{
    return [CVUtils loadImage:fileName withExtraLayers:nil layers:layers];
}

+(UIImage*)loadImage:(NSString*)fileName withExtraLayers:(NSString*)extraLayersFileName layers:(uint8_t)layers
{
    HeaderOptions header;
    HuffmanTree *tree = Utilities::OpenFile(string([fileName cStringUsingEncoding:NSASCIIStringEncoding]), header);
    
    if (extraLayersFileName)
    {
        ifbitstream extraLayerFile([extraLayersFileName cStringUsingEncoding:NSASCIIStringEncoding]);
        
        for (uint8_t i = 0; i < (layers - tree->getLayerCount()); i++)
            HuffmanTree::AddLayer(extraLayerFile, tree);
    }
    
    Mat inFileImage = Utilities::ToMat(tree, &header, layers);
    delete tree;
    
    cvtColor(inFileImage, inFileImage, CV_BGR2RGB);
    
    return [CVUtils UIImageFromCVMat:inFileImage];
}

+(UIImage*)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
