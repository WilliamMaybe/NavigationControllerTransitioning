//
//  MagicMoveInverseTransition.m
//  NavigationControllerTransitioning
//
//  Created by williamzhang on 16/5/10.
//  Copyright © 2016年 williamzhang. All rights reserved.
//

#import "MagicMoveInverseTransition.h"
#import "CollectionViewController.h"
#import "DetailViewController.h"
#import "CollectionViewCell.h"

#define MagicMoveInverseDuration 0.6

@interface MagicMoveInverseTransition ()

@property (nonatomic ,strong) UIViewController *viewController;

@end

@implementation MagicMoveInverseTransition

- (void)panToDismiss:(UIViewController *)viewController {
    self.viewController = viewController;
    
    UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGesture:)];
    gesture.edges = UIRectEdgeLeft;
    [viewController.view addGestureRecognizer:gesture];
}

- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    CGFloat progress = [gesture translationInView:self.viewController.view].x / self.viewController.view.bounds.size.width;
    
    progress = MIN(MAX(0, progress), 1);
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _interactive = YES;
            [self.viewController.navigationController popViewControllerAnimated:YES];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (progress > 0.5) {
                [self finishInteractiveTransition];
            }
            else {
                [self cancelInteractiveTransition];
            }
            _interactive = NO;
            break;
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return MagicMoveInverseDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    DetailViewController *fromVC   = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CollectionViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *snapshotView = [fromVC.imageView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [containerView convertRect:fromVC.imageView.frame fromView:fromVC.view];
    fromVC.imageView.hidden = YES;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    CollectionViewCell *selectedCell = (CollectionViewCell *)[toVC.collectionView cellForItemAtIndexPath:toVC.selectedIndexPath];
    selectedCell.imageView.hidden = YES;
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    
    [UIView animateWithDuration:MagicMoveInverseDuration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         snapshotView.frame = [containerView convertRect:selectedCell.imageView.frame fromView:selectedCell.contentView];
                         toVC.view.alpha = 1;
                         
                     }
                     completion:^(BOOL finished) {
                        
                         [snapshotView removeFromSuperview];
                         fromVC.imageView.hidden = NO;
                         selectedCell.imageView.hidden = NO;
        
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }
     ];
}

@end
