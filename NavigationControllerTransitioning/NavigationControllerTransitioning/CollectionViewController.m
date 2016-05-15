//
//  CollectionViewController.m
//  NavigationControllerTransitioning
//
//  Created by williamzhang on 16/5/10.
//  Copyright © 2016年 williamzhang. All rights reserved.
//

#import "CollectionViewController.h"
#import "MagicMoveInverseTransition.h"
#import "DetailViewController.h"
#import "MagicMoveTransition.h"

@interface CollectionViewController () <UINavigationControllerDelegate>

@property (nonatomic ,strong) MagicMoveInverseTransition *moveInverseTransition;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionViewIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
        
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.moveInverseTransition = [MagicMoveInverseTransition new];
    UIViewController *dst = segue.destinationViewController;
    [self.moveInverseTransition panToDismiss:dst];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(270, 300);
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 15;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 15;
//}

#pragma mark - UINavigationController Delegate
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

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[MagicMoveInverseTransition class]]) {
        return self.moveInverseTransition.interactive ? self.moveInverseTransition : nil;
    }
    
    return nil;
}

@end
