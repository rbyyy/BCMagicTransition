//
//  BCMagicTransition.m
//  BCMagicTransition
//
//  Created by Xaiobo Zhang on 10/21/14.
//  Copyright (c) 2014 Xaiobo Zhang. All rights reserved.
//

#import "BCMagicTransition.h"

@interface BCMagicTransition ()

@end

@implementation BCMagicTransition

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [toVC.view layoutIfNeeded];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isMagic) {
        [self magicAnimationFromViewController:fromVC toViewController:toVC containerView:containerView duration:self.duration transitionContext:transitionContext];
    } else {
        [self defaultAnimationFromViewController:fromVC toViewController:toVC containerView:containerView duration:self.duration transitionContext:transitionContext];
    }
}

#pragma mark - private
- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}


- (void)defaultAnimationFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController containerView:(UIView *)containerView duration:(NSTimeInterval)duration transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    float deviation = (self.isPush) ? 1.0f : -1.0f;
    
    CGRect newFrame = toViewController.view.frame;
    newFrame.origin.x += newFrame.size.width*deviation;
    toViewController.view.frame = newFrame;
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect animationFrame = toViewController.view.frame;
        animationFrame.origin.x -= animationFrame.size.width*deviation;
        toViewController.view.frame = animationFrame;
        
        animationFrame = fromViewController.view.frame;
        animationFrame.origin.x -= animationFrame.size.width*deviation;
        fromViewController.view.frame = animationFrame;
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}

- (void)magicAnimationFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController containerView:(UIView *)containerView duration:(NSTimeInterval)duration transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    NSAssert([self.fromViews count] == [self.toViews count], @"*** The count of fromviews and toviews must be the same! ***");
    
    NSMutableArray *fromViewSnapshotArray = [[NSMutableArray alloc] init];
    for (UIView *fromView in self.fromViews) {
        UIImageView *fromViewSnapshot = [[UIImageView alloc] initWithImage:[self getImageFromView:fromView]];
        fromViewSnapshot.frame = [containerView convertRect:fromView.frame fromView:fromView.superview];
        [fromViewSnapshotArray addObject:fromViewSnapshot];
        fromView.alpha = 0.0;
    }
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    [containerView addSubview:toViewController.view];
    
    for (UIView *toView in self.toViews) {
        toView.alpha = 0.0;
    }
    
    for (NSUInteger i = [fromViewSnapshotArray count]; i > 0; i--) {
        [containerView addSubview:[fromViewSnapshotArray objectAtIndex:i - 1]];
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toViewController.view.alpha = 1.0;
                         for (NSUInteger i = 0; i < [self.fromViews count]; i++) {
                             UIView *toView = [self.toViews objectAtIndex:i];
                             UIView *fromViewSnapshot = [fromViewSnapshotArray objectAtIndex:i];
                             CGRect frame = [containerView convertRect:toView.frame fromView:toView.superview];
                             fromViewSnapshot.frame = frame;
                         }
                     } completion:^(BOOL finished) {
                         for (NSUInteger i = 0; i < [self.fromViews count]; i++) {
                             UIView *toView = [self.toViews objectAtIndex:i];
                             UIView *fromView = [self.fromViews objectAtIndex:i];
                             UIView *fromViewSnapshot = [fromViewSnapshotArray objectAtIndex:i];
                             toView.alpha = 1.0;
                             fromView.alpha = 1.0;
                             [fromViewSnapshot removeFromSuperview];
                         }
                         
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
