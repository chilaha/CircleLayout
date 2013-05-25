//
//  CircleLayout.m
//  CircleLayout
//
//  Created by Scott Saia on 5/25/13.
//  Copyright (c) 2013 Scott Saia. All rights reserved.
//

#import "CircleLayout.h"

@interface CircleLayout ()

@property (strong, nonatomic) NSMutableArray *deletePaths;
@property (strong, nonatomic) NSMutableArray *insertPaths;

@end

@implementation CircleLayout

#define ITEM_SIZE 70

// 2 very important methods for custom views - prepareLayout and collectionViewContentSize
- (void)prepareLayout
{
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    
    _cellCount = [[self collectionView] numberOfItemsInSection:0];
    
    _center = CGPointMake(size.width / 2, size.height / 2);
    _radius = MIN(size.width, size.height) / 2.5;
}

- (CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}

// 2 methods need to implement like other layouts
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * indexPath.item * M_PI / _cellCount),
                                    _center.y + _radius * sinf(2 * indexPath.item * M_PI / _cellCount));
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0; i < self.cellCount; i++) {
        // build indexpath for cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // reuse layoutAttributesForItemAtIndexPath method for cell
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

// had to add some methods since Apple changed API for UICV
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deletePaths = [NSMutableArray array];
    self.insertPaths = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [updateItems count]; i++) {
        UICollectionViewUpdateItem *item = updateItems[i];
        if (item.updateAction == UICollectionUpdateActionDelete) {
            [self.deletePaths addObject:item.indexPathBeforeUpdate];
        } else if (item.updateAction == UICollectionUpdateActionInsert) {
            [self.insertPaths addObject:item.indexPathAfterUpdate];
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if (attributes && [self.insertPaths containsObject:itemIndexPath]) {
        // start cell out at center and invisible for animation
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if (attributes && [self.deletePaths containsObject:itemIndexPath]) {
        // end of cell is in center and invisible and shrinking for animation
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    }
    return attributes;
}

@end
