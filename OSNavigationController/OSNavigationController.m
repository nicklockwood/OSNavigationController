//
//  OSNavigationController.h
//
//  Version 1.0
//
//  Created by Nick Lockwood on 01/06/2013.
//  Copyright (C) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/OSNavigationController
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "OSNavigationController.h"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@implementation NSObject (OSNavigationController)

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {};
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {};

@end


@interface OSNavigationController () <UINavigationBarDelegate>

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@end


@implementation OSNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)viewController
{
    if ((self = [self initWithNibName:nil bundle:nil]))
    {
        self.viewControllers = @[viewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.viewControllers = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateViewsAnimated:NO];
}

- (void)setNavigationBar:(UINavigationBar *)navigationBar
{
    _navigationBar.delegate = nil;
    _navigationBar = navigationBar;
    _navigationBar.delegate = self;
}

- (void)updateViewsAnimated:(BOOL)animated
{
    UIViewController *controller = self.topViewController;
    
    //update navigation bar
    [_navigationBar setItems:@[controller.navigationItem] animated:animated];
    
    //update content view
    if (animated)
    {
        CATransition* transition = [CATransition animation];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = 0.4;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [self.contentView.layer addAnimation:transition forKey:nil];
    }
    [[_contentView.subviews lastObject] removeFromSuperview];
    controller.view.frame = _contentView.bounds;
    [_contentView addSubview:controller.view];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    //get old view controller
    UIViewController *oldViewController = self.topViewController;
    for (UIViewController *controller in _viewControllers)
    {
        [controller removeFromParentViewController];
    }
    
    //replace view controllers
    _viewControllers = viewControllers;
    for (UIViewController *controller in _viewControllers)
    {
        [self addChildViewController:controller];
    }
    
    //add new view controller
    UIViewController *controller = self.topViewController;
    if (controller != oldViewController)
    {
        if (controller)
        {
            //force view to load
            [self view];
            controller.view.frame = _contentView.bounds;
            
            [_delegate navigationController:(UINavigationController *)self
                     willShowViewController:controller
                                   animated:animated];
            
            [oldViewController viewWillDisappear:animated];
            [controller viewWillAppear:animated];
            [self updateViewsAnimated:animated];
            [oldViewController viewDidDisappear:animated];
            [controller viewDidAppear:animated];
            
            [_delegate navigationController:(UINavigationController *)self
                      didShowViewController:controller
                                   animated:animated];
        }
        
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //get old view controller
    UIViewController *oldViewController = self.topViewController;
    
    //replace view controllers
    _viewControllers = [_viewControllers ?: @[] arrayByAddingObject:viewController];
    [self addChildViewController:viewController];
    
    //add new view controller
    UIViewController *controller = self.topViewController;
    if (controller != oldViewController)
    {
        if (controller)
        {
            //force view to load
            controller.view.frame = _contentView.bounds;
            
            [_delegate navigationController:(UINavigationController *)self
                     willShowViewController:controller
                                   animated:animated];
            
            //update navigation bar
            [_navigationBar pushNavigationItem:controller.navigationItem
                                      animated:animated];
            
            //update content view
            if (animated)
            {
                CATransition* transition = [CATransition animation];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = 0.33;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromRight;
                [self.contentView.layer addAnimation:transition forKey:nil];
            }
            [oldViewController viewWillDisappear:animated];
            [controller viewWillAppear:animated];
            [oldViewController.view removeFromSuperview];
            [_contentView addSubview:controller.view];
            [oldViewController viewDidDisappear:animated];
            [controller viewDidAppear:animated];
            
            [_delegate navigationController:(UINavigationController *)self
                      didShowViewController:controller
                                   animated:animated];
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if ([_viewControllers count] > 1)
    {
        return [[self popToViewController:_viewControllers[[_viewControllers count] - 2]
                         animated:animated] lastObject];
    }
    return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:self.viewControllers[0] animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //get old view controller
    UIViewController *oldViewController = self.topViewController;
    
    //pop to specified controller
    NSMutableArray *poppedControllers = [NSMutableArray array];
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:_viewControllers];
    while ([controllers lastObject] && [controllers lastObject] != viewController)
    {
        [poppedControllers addObject:[controllers lastObject]];
        [[controllers lastObject] removeFromParentViewController];
        [controllers removeLastObject];
    }
    _viewControllers = [controllers copy];
    
    //add new view controller
    UIViewController *controller = self.topViewController;
    if (controller != oldViewController)
    {
        if (controller)
        {
            //force view to load
            controller.view.frame = _contentView.bounds;
            
            [_delegate navigationController:(UINavigationController *)self
                     willShowViewController:controller
                                   animated:animated];
            
            //update navigation bar
            [_navigationBar setItems:[controllers valueForKeyPath:@"navigationItem"]
                            animated:animated];
            
            //update content view
            if (animated)
            {
                CATransition* transition = [CATransition animation];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = 0.33;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                [self.contentView.layer addAnimation:transition forKey:nil];
            }
            [oldViewController viewWillDisappear:animated];
            [controller viewWillAppear:animated];
            [[_contentView.subviews lastObject] removeFromSuperview];
            [_contentView addSubview:controller.view];
            [oldViewController viewDidDisappear:animated];
            [controller viewDidAppear:animated];
            
            [_delegate navigationController:(UINavigationController *)self
                      didShowViewController:controller
                                   animated:animated];
        }
    }
    
    return poppedControllers;
}

- (UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (BOOL)navigationBarHidden
{
    return _navigationBar.frame.origin.y < 0;
}

- (void)setNavigationBarHidden:(BOOL)hidden
{
    CGRect frame = _navigationBar.frame;
    frame.origin.y = hidden? -frame.size.height: 0;
    _navigationBar.frame = frame;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated)
    {
        self.navigationBarHidden = hidden;
    }
    else if (hidden != self.navigationBarHidden)
    {
        [UIView animateWithDuration:0.33 animations:^{
            self.navigationBarHidden = hidden;
        }];
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self popViewControllerAnimated:YES];
    return NO;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    if (aClass == [UINavigationController class])
    {
        return YES;
    }
    return [super isKindOfClass:aClass];
}

@end
