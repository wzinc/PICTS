//
//  DetailViewController.h
//  PICTS
//
//  Created by William Zink on 3/30/17.
//  Copyright © 2017 William Zink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *pictureDetail;

@end

