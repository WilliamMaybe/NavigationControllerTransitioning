//
//  MagicMoveInverseTransition.h
//  NavigationControllerTransitioning
//
//  Created by williamzhang on 16/5/10.
//  Copyright © 2016年 williamzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagicMoveInverseTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

- (void)panToDismiss:(UIViewController *)viewController;

@property (nonatomic ,readonly) BOOL interactive;

@end
