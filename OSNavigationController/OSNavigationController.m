//
//  OSNavigationController.h
//
//  Version 1.0.3
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
@property (nonatomic, weak) IBOutlet UIView *transitionView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, assign) CGFloat navigationBarHeight;

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
        _viewControllers = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarHidden = self.navigationBarHidden;
    self.viewControllers = self.viewControllers;
}

- (void)setNavigationBar:(UINavigationBar *)navigationBar
{
    _navigationBar.delegate = nil;
    _navigationBar = navigationBar;
    _navigationBar.delegate = self;
    _navigationBarHeight = navigationBar.frame.size.height;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    //get popped controllers
    for (UIViewController *controller in self.viewControllers)
    {
        if (![viewControllers containsObject:controller])
        {
            [controller removeFromParentViewController];
        }
    }
    
    //get pushed controllers
    NSString *direction = kCATransitionFromLeft;
    for (UIViewController *controller in viewControllers)
    {
        if (![self.viewControllers containsObject:controller])
        {
            direction = kCATransitionFromRight;
            [self addChildViewController:controller];
        }
    }
    
    //update view
    UIViewController *oldViewController = self.topViewController;
    _viewControllers = [viewControllers copy];
    UIViewController *controller = self.topViewController;
    if (_contentView && controller.view.superview != _contentView)
    {
        [_delegate navigationController:(UINavigationController *)self
                 willShowViewController:controller
                               animated:animated];
        
        //update navigation bar
        NSArray *navigationItems = [viewControllers valueForKeyPath:@"navigationItem"];
        [_navigationBar setItems:navigationItems animated:animated];
        
        //update content
        if (animated)
        {
            CATransition *transition = [CATransition animation];
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.duration = 0.33;
            transition.type = kCATransitionPush;
            transition.subtype = direction;
            [self.transitionView.layer addAnimation:transition forKey:nil];
            
            controller.view.frame = _contentView.bounds;
            [UIView transitionFromView:oldViewController.view toView:controller.view duration:0 options:UIViewAnimationOptionTransitionNone completion:NULL];
        }
        else
        {
            controller.view.frame = _contentView.bounds;
            [oldViewController.view removeFromSuperview];
            [_contentView addSubview:controller.view];
        }
        
        [_delegate navigationController:(UINavigationController *)self
                  didShowViewController:controller
                               animated:animated];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setViewControllers:[self.viewControllers arrayByAddingObject:viewController] animated:animated];
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
    //pop to specified controller
    NSMutableArray *poppedControllers = [NSMutableArray array];
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:_viewControllers];
    while ([controllers lastObject] && [controllers lastObject] != viewController)
    {
        [poppedControllers addObject:[controllers lastObject]];
        [[controllers lastObject] removeFromParentViewController];
        [controllers removeLastObject];
    }
    
    [self setViewControllers:controllers animated:animated];
    
    return poppedControllers;
}

- (UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (void)setNavigationBarHidden:(BOOL)hidden
{
    _navigationBarHidden = hidden;
    [self.view layoutIfNeeded];
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = _navigationBar.frame;
    if (self.view.window.rootViewController == self && [[UIDevice currentDevice].systemVersion floatValue] >= 7)
    {
        CGSize statusFrame = [UIApplication sharedApplication].statusBarFrame.size;
        frame.size.height = _navigationBarHeight + MIN(statusFrame.height, statusFrame.width);
    }
    frame.origin.y = _navigationBarHidden? -frame.size.height: 0;
    _navigationBar.frame = frame;
    frame = _contentView.frame;
    frame.origin.y = _navigationBarHidden? 0: _navigationBar.frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    _contentView.frame = frame;
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
    //pretend that we're a UINavigationController if anyone asks
    if (aClass == [UINavigationController class])
    {
        return YES;
    }
    return [super isKindOfClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    //protect against calls to unimplemented UINavigationController methods
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature)
    {
        signature = [UINavigationController instanceMethodSignatureForSelector:selector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:nil];
}

@end
