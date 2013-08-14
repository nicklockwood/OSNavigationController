//
//  DetailViewController.h
//  NavigationExample
//
//  Created by Nick Lockwood on 14/08/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
