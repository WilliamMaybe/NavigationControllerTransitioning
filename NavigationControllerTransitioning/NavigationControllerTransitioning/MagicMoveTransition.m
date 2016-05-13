//
//  MagicMoveTransition.m
//  NavigationControllerTransitioning
//
//  Created by williamzhang on 16/5/10.
//  Copyright © 2016年 williamzhang. All rights reserved.
//

#import "MagicMoveTransition.h"
#import "CollectionViewController.h"
#import "DetailViewController.h"
#import "CollectionViewCell.h"

@implementation MagicMoveTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CollectionViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DetailViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UICollectionView *collectionView = fromVC.collectionView;
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:[collectionView indexPathsForSelectedItems].firstObject];
    
    // 获取到截图并计算出相对应的frame
    UIView *snapshotView = [cell.imageView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    
    cell.imageView.alpha = 0;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    toVC.imageView.hidden = YES;
    
    // 添加顺序很重要
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^
    {
        [containerView layoutIfNeeded];
        toVC.view.alpha = 1;
        snapshotView.frame = [containerView convertRect:toVC.imageView.frame fromView:toVC.view];
    
    } completion:^(BOOL finished) {
        toVC.imageView.hidden = NO;
        
        [snapshotView removeFromSuperview];
        [transitionContext completeTransition:YES];
        cell.imageView.alpha = 1;
    }];
    
}

@end
