#import "DetailViewController.h"
#import "CVUtils.h"

@interface DetailViewController ()
{
    NSString* _mainFilePath;
    NSString* _extraLayersFilePath;
    NSUInteger _lastValue;
    
}
@property (weak, nonatomic) IBOutlet UILabel *layerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *fullScreenSwitch;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

-(void)configureView
{
    if (!self.detailItem)
        return;
    
    _mainFilePath = (NSString*)self.detailItem;
    NSString *fileName = [NSURL fileURLWithPath:_mainFilePath].lastPathComponent;
    self.navigationItem.title = fileName;
    
    NSUInteger viewHeight = (NSUInteger)self.view.frame.size.height;
    NSUInteger imageHeight = [CVUtils getImageHeight:_mainFilePath];
    NSUInteger layer0Height = imageHeight / 8;
    
    NSInteger neededLayers = 1;
    for (; layer0Height * neededLayers < viewHeight; neededLayers++);
    
    NSLog(@"viewHeight: %ld", viewHeight);
    NSLog(@"imageHeight: %ld", imageHeight);
    NSLog(@"neededLayers: %ld", neededLayers);
    NSLog(@"layersHeight: %ld", neededLayers * layer0Height);
    
    // get more layers
    NSString *layers = [NSString stringWithFormat:@"2-%ld", neededLayers];
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
    
    _extraLayersFilePath = cachedImageUrl.relativePath;
    NSLog(@"extra layers path: %@", cachedImageUrl.relativePath);
    
    NSDictionary *baseFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_mainFilePath error:nil];
    double baseFileSize = ((NSNumber*)baseFileAttributes[NSFileSize]).doubleValue / 1024.0;
    
    NSDictionary *extraFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cachedImageUrl.relativePath error:nil];
    double extraFileSize = ((NSNumber*)extraFileAttributes[NSFileSize]).doubleValue / 1024.0;
    
    NSLog(@"baseFileSize: %f | extraFileSize: %f", baseFileSize, extraFileSize);
    
    self.pictureDetail.text = [NSString stringWithFormat:@"Thumbnail: %.2f KB\nUpper Layers: %.2f KB\nSavings: %.2f%%", baseFileSize, extraFileSize, ((double)baseFileSize / (double)(baseFileSize + extraFileSize)) * 100.0];
    
    [self showImage];
    
    _layerSlider.maximumValue = neededLayers;
//    _layerSlider.continuous = false;
}

- (void)showImage
{
    self.pictureView.image = [CVUtils loadImage:_mainFilePath withExtraLayers:_extraLayersFilePath layers:(uint8_t)self.layerSlider.value];
    _layerLabel.text = [NSString stringWithFormat:@"%d", (int)_layerSlider.value];
}

- (IBAction)layerValueChanged:(id)sender
{
    NSUInteger newValue = _layerSlider.value;
    
    if (newValue != _lastValue)
    {
        [self showImage];
        _lastValue = newValue;
    }
}

- (IBAction)fullScreenSwitchToggle:(id)sender
{
    self.pictureView.contentMode = _fullScreenSwitch.on ? UIViewContentModeScaleAspectFill : UIViewContentModeCenter;
}
@end
