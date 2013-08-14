//
//  MasterViewController.h
//  NavigationExample
//
//  Created by Nick Lockwood on 14/08/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
