//
//  DWFlowLayout.m
//  CardSlide
//
//  Created by DavidWang on 15/11/25.
//  Copyright © 2015年 DavidWang. All rights reserved.
//

#import "DWFlowLayout.h"

@implementation DWFlowLayout

-(id)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 20.0;
        self.sectionInset = UIEdgeInsetsMake(0,30, 0,30);
    }
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offSetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = (CGFloat) (proposedContentOffset.x + (self.collectionView.bounds.size.width / 2.0));
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [self layoutAttributesForElementsInRect:targetRect];
    
    UICollectionViewLayoutAttributes *currentAttributes;
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            CGFloat itemHorizontalCenter = layoutAttributes.center.x;
            if (ABS(itemHorizontalCenter - horizontalCenter) <  ABS(offSetAdjustment))
            {
                currentAttributes   = layoutAttributes;
                offSetAdjustment    = itemHorizontalCenter - horizontalCenter;
            }
        }
    }
    
    CGFloat nextOffset          = proposedContentOffset.x + offSetAdjustment;
    
    proposedContentOffset.x     = nextOffset;
    CGFloat deltaX              = proposedContentOffset.x - self.collectionView.contentOffset.x;
    CGFloat velX                = velocity.x;
    
    if(deltaX == 0.0 || velX == 0 || (velX >  0.0  &&  deltaX >  0.0) || (velX <  0.0 &&  deltaX <  0.0)) {
        
    } else if(velocity.x >  0.0) {
        for (UICollectionViewLayoutAttributes *layoutAttributes in array)
        {
            if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
            {
                CGFloat itemHorizontalCenter = layoutAttributes.center.x;
                if (itemHorizontalCenter >  proposedContentOffset.x) {
                    proposedContentOffset.x = nextOffset + (currentAttributes.frame.size.width / 2) + (layoutAttributes.frame.size.width / 2);
                    break;
                }
            }
        }
    } else if(velocity.x <  0.0) {
        for (UICollectionViewLayoutAttributes *layoutAttributes in array)
        {
            if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
            {
                CGFloat itemHorizontalCenter = layoutAttributes.center.x;
                if (itemHorizontalCenter >  proposedContentOffset.x) {
                    proposedContentOffset.x = nextOffset - ((currentAttributes.frame.size.width / 2) + (layoutAttributes.frame.size.width / 2));
                    break;
                }
            }
        }
    }
    
    proposedContentOffset.y = 0.0;
    
    if (proposedContentOffset.x == -0.0) {
        proposedContentOffset.x = 0.0;
    }
    
    NSLog(@"%f",proposedContentOffset.x);
    return proposedContentOffset;
}





static CGFloat const ActiveDistance = 350;
static CGFloat const ScaleFactor = 0.05;

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
        CGFloat normalizedDistance = distance / ActiveDistance;
        CGFloat zoom = 1 + ScaleFactor*(1 - ABS(normalizedDistance));
        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
        attributes.zIndex = 1;
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
