#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PreviewCollectionViewCell.h"
#import "CVUtils.h"

@interface MasterViewController ()

@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self loadImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.collectionView reloadData];
}

-(void)loadImages
{
    if (!self.objects)
        self.objects = [[NSMutableArray alloc] init];

    // get file list
    NSURLRequest *listRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.0.41:8081/list"]];
    
    NSURLResponse *response = nil;
    NSData *listData = [NSURLConnection sendSynchronousRequest:listRequest returningResponse:&response error:nil];
    NSDictionary *list = [NSJSONSerialization JSONObjectWithData:listData options:kNilOptions error:nil];
    
//    NSString *baseUrl = @"http://10.0.0.41:8081/get/%@/%d";
    NSString *baseUrl = @"http://10.0.0.41:8081/get/%@/1";
    NSLog(@"Loaded %lu images.", list.count);
    
    // save files here
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSURL *cacheUrl = [NSURL fileURLWithPath:cacheDirectory];
    
    for (NSString *imageName in list)
    {
        NSString *imageUrl = [NSString stringWithFormat:baseUrl, imageName];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl] options:kNilOptions error:nil];
//        NSLog(@"Downloaded image: %@ (%lu B)", imageUrl, imageData.length);
        
        NSURL *cachedImageUrl = [cacheUrl URLByAppendingPathComponent:imageName];
        [imageData writeToURL:cachedImageUrl atomically:true];
        
//        NSLog(@"cachedImageUrl: %@", cachedImageUrl);
        
        [self.objects insertObject:cachedImageUrl.relativePath atIndex:0];
    }
    
    NSLog(@"self.objects.count: %lu", self.objects.count);
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.objects.count; }

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PreviewCollectionViewCell *cell = (PreviewCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell" forIndexPath:indexPath];
    NSString *imagePath = self.objects[indexPath.row];
    
    cell.previewImage.image = [CVUtils loadImage:imagePath layers:8];
    
    return cell;
}
@end
