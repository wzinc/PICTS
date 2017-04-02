#import "DetailViewController.h"
#import "CVUtils.h"

@implementation DetailViewController

-(void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem)
    {
        NSString *filePath = (NSString*)self.detailItem;
        NSString *fileName = [NSURL fileURLWithPath:filePath].lastPathComponent;
        self.navigationItem.title = fileName;
        
        // get more layers
        NSString *layers = @"3-8";
        NSString *baseUrl = @"http://10.0.0.41:8081/get/%@/%@";
        
        // save files here
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSURL *cacheUrl = [NSURL fileURLWithPath:cacheDirectory];
        
        NSString *imageUrl = [NSString stringWithFormat:baseUrl, fileName, layers];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl] options:kNilOptions error:nil];
        NSLog(@"Downloaded image: %@ (%lu B)", imageUrl, imageData.length);
        
        NSURL *cachedImageUrl = [cacheUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, layers]];
        [imageData writeToURL:cachedImageUrl atomically:true];
        
        NSLog(@"extra layers path: %@", cachedImageUrl.relativePath);
        
        NSDictionary *baseFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        long long baseFileSize = ((NSNumber*)baseFileAttributes[NSFileSize]).longLongValue;
        
        NSDictionary *extraFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cachedImageUrl.relativePath error:nil];
        long long extraFileSize = ((NSNumber*)extraFileAttributes[NSFileSize]).longLongValue;
        
        NSLog(@"baseFileSize: %lld | extraFileSize: %lld", baseFileSize, extraFileSize);
        
        self.pictureView.image = [CVUtils loadImage:filePath withExtraLayers:cachedImageUrl.relativePath layers:8];
        
        self.pictureDetail.text = [NSString stringWithFormat:@"base: %lld; extra: %lld\nsavings: %.2f%%", baseFileSize, extraFileSize, ((double)baseFileSize / (double)(baseFileSize + extraFileSize)) * 100.0];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDate *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}
@end
