# NavigationControllerTransitioning
navigationControl转场demo

[iOS自定义转场详解02——实现Keynote中的神奇移动效果](http://www.kittenyang.com/magicmove/)
##开头
这次做的转场是基于navigationController，个人感觉和present的方式差不多，present的[demo](https://github.com/WilliamMaybe/ViewControllerTransitionTest)
##准备
首先创建`CollectionViewController`和`DetailViewController`，然后在storyboard中配置好相关的联系。
接下来创建一个`MagicMoveTranstion`继承于NSObject，实现UIViewControllerAnimatedTransitioning协议，这个和present都一样，不清楚跳转[demo](https://github.com/WilliamMaybe/ViewControllerTransitionTest)查看

实现2个协议方法	

```
@implementation MagicMoveTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CollectionViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DetailViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UICollectionView *collectionView = fromVC.collectionView;
    fromVC.selectedIndexPath = [collectionView indexPathsForSelectedItems].firstObject;
    
    // 获取到我们点击的Cell
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:fromVC.selectedIndexPath];
    
    // 获取到截图并计算出相对应的frame
    // 点击Cell的imageView截图
    UIView *snapshotView = [cell.imageView snapshotViewAfterScreenUpdates:NO];
    // 计算在containerView中的相应frame
    snapshotView.frame = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    
    cell.imageView.alpha = 0;
    
    // DetailVC中imageView先设置为隐藏，最后动画完成时显示
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    toVC.imageView.hidden = YES;
    
    // 添加顺序很重要
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapshotView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear animations:^ {
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

```
完成之后在CollectionViewController中加上相应的方法，需要注意的是，因为这次是给UINavigationController的push事件做动画，所以需要完成的是UINavigationControllerDelegate

```
@interface CollectionViewController () <UINavigationControllerDelegate>
@end

@implementation CollectionViewController

#pragma mark - UINavigationController Delegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(nonnull UIViewController *)fromVC toViewController:(nonnull UIViewController *)toVC
{
    if ([toVC isKindOfClass:[DetailViewController class]]) {
        return [MagicMoveTransition new];
    }
    
    return nil;
}


@end

```
就此，push的动画就完成了。
接下来pop的动画类似，创建一个`MagicMoveInverseTransition`继承于`UIPercentDrivenInteractiveTransition`，在之后的手势百分比动画中需要使用到这个类

```
#define MagicMoveInverseDuration 0.6

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

	// 其实就是将push的方法反着做一遍，不描述了

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

```

在viewController中一样完成方法

```
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(nonnull UIViewController *)fromVC toViewController:(nonnull UIViewController *)toVC
{
    if ([toVC isKindOfClass:[DetailViewController class]]) {
        return [MagicMoveTransition new];
    }
    
    if ([toVC isKindOfClass:[CollectionViewController class]]) {
        return [MagicMoveInverseTransition new];
    }
    
    return nil;
}
```

ok，转场效果都完成了，接下来做更炫酷的东西
##手势动画
这里我们就要用到继承于`UIPercentDrivenInteractiveTransition`的MagicMoveInverseTransition了，加上一个方法

```
// MagicMoveInverseTransition.h
@interface MagicMoveInverseTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

- (void)panToDismiss:(UIViewController *)viewController;

@property (nonatomic ,readonly) BOOL interactive;

@end

// MagicMoveInverseTransition.m
@interface MagicMoveInverseTransition ()

@property (nonatomic ,strong) UIViewController *viewController;

@end

@implementation MagicMoveInverseTransition

- (void)panToDismiss:(UIViewController *)viewController {
    self.viewController = viewController;
    
    // 给push出来的VC加上手势
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
@end

```

接着，在`CollectionViewController`中push的时候使用该方法

```
@interface CollectionViewController () <UINavigationControllerDelegate>

@property (nonatomic ,strong) MagicMoveInverseTransition *moveInverseTransition;

@end

@implementation CollectionViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.moveInverseTransition = [MagicMoveInverseTransition new];
    UIViewController *dst = segue.destinationViewController;
    [self.moveInverseTransition panToDismiss:dst];
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[MagicMoveInverseTransition class]]) {
        return self.moveInverseTransition.interactive ? self.moveInverseTransition : nil;
    }
    
    return nil;
}

@end

```

OK，手势动画也完成了，不过有一点比较好奇，与present的时候不一样，小王子是将MagicMoveInverseTransition继承于NSObject的，然后在DetailViewController中加入手势的，和我做法不一样。

##补充一个知识：

IOS－－ UIView中的坐标转换

// 将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值

- (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view;

// 将像素point从view中转换到当前视图中，返回在当前视图中的像素值

- (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view;

// 将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect

- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;

// 将rect从view中转换到当前视图中，返回在当前视图中的rect

- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;

##总结
当初在自己看来很炫酷也很“难”的东西，其实不难，真心要花些时间看看，心还是太浮躁，呆在家里受到诱惑太多，总是想看直播、玩游戏。