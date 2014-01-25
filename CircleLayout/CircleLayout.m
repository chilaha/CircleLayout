//
//  CircleLayout.m
//  CircleLayout
//
//  Created by Scott Saia on 5/25/13.
//  Copyright (c) 2013 Scott Saia. All rights reserved.
//

#import "CircleLayout.h"

@interface CircleLayout ()

@property (strong, nonatomic) NSMutableArray *deleteIndexPaths;
@property (strong, nonatomic) NSMutableArray *insertIndexPaths;
@property (strong, nonatomic) NSMutableArray *moveCVUpdateItems;

@end

@implementation CircleLayout

#define ITEM_SIZE 70

- (void)setPressedCellIndexPath:(NSIndexPath *)pressedCellIndexPath
{
    _pressedCellIndexPath = pressedCellIndexPath;
    [self invalidateLayout];
}

- (void)setPressedPoint:(CGPoint)pressedPoint
{
    _pressedPoint = pressedPoint;
    [self invalidateLayout];
}



// 2 very important methods for custom views - prepareLayout and collectionViewContentSize
- (void)prepareLayout
{
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    
    self.innerCellCount = [self.collectionView numberOfItemsInSection:1];
    self.outerCellCount = [self.collectionView numberOfItemsInSection:0];
    
    self.center = CGPointMake(size.width / 2, size.height / 2);
    self.radius = MIN(size.width, size.height) / 2.5;
}

- (CGSize)collectionViewContentSize
{
    return self.collectionView.frame.size;
}

// 2 methods need to implement like other layouts
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    NSInteger cellCount = indexPath.section ? self.innerCellCount : self.outerCellCount;
    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * indexPath.item * M_PI / cellCount) / (indexPath.section + 1),
                                    _center.y + _radius * sinf(2 * indexPath.item * M_PI / cellCount) / (indexPath.section + 1));
    // apply special attributes during dragging cell
    [self applyPressToLayoutAttributes:attributes];

    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSInteger count = section ? self.innerCellCount : self.outerCellCount;
        for (NSInteger item = 0; item < count; item++) {
            // build indexpath for cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            // reuse layoutAttributesForItemAtIndexPath method for cell
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return attributes;
}


#define CELL_UPSCALE 1.1 // 10% scaled up

- (void)applyPressToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    // if a cell selected
    if (self.pressedCellIndexPath) {
        // if this is selected cell
        if ([layoutAttributes.indexPath isEqual:self.pressedCellIndexPath]) {
            layoutAttributes.center = self.pressedPoint;
        }
        // grow any cells underneath our dragging cell
        if (CGRectContainsPoint(layoutAttributes.frame, self.pressedPoint)) {
            layoutAttributes.transform3D = CATransform3DMakeScale(CELL_UPSCALE, CELL_UPSCALE, 1.0);
        }
    }
}



// called when there are about to be changes so the layout can prepare
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    self.moveCVUpdateItems = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [updateItems count]; i++) {
        UICollectionViewUpdateItem *item = updateItems[i];
        if (item.updateAction == UICollectionUpdateActionDelete) {
            [self.deleteIndexPaths addObject:item.indexPathBeforeUpdate];
        } else if (item.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:item.indexPathAfterUpdate];
        } else if (item.updateAction == UICollectionUpdateActionMove) {
            [self.moveCVUpdateItems addObject:item];
        }
    }
}

// for cells being inserted or moved (initial moving state)
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // for move get initial state from items initial indexPath
    for (UICollectionViewUpdateItem *item in self.moveCVUpdateItems) {
        if (item.indexPathAfterUpdate == itemIndexPath) {
            UICollectionViewLayoutAttributes *beforeUpdateAttributes = [self layoutAttributesForItemAtIndexPath:item.indexPathBeforeUpdate];
            return beforeUpdateAttributes; // simply return the before update attributes
        }
    }
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if (attributes && [self.insertIndexPaths containsObject:itemIndexPath]) {
        // start cell out at center and invisible for animation
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(self.center.x, self.center.y);
    }
    return attributes;
}

// for cell being deleted or for moved (final moving state)
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // for move get final state from items final indexPath
    for (UICollectionViewUpdateItem *item in self.moveCVUpdateItems) {
        if (item.indexPathBeforeUpdate == itemIndexPath) {
            UICollectionViewLayoutAttributes *afterUpdateAttributes = [self layoutAttributesForItemAtIndexPath:item.indexPathAfterUpdate];
            return afterUpdateAttributes; // simply return the after update attributes
        }
    }
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if (attributes && [self.deleteIndexPaths containsObject:itemIndexPath]) {
        // end of cell is in center and invisible and shrinking for animation
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    }
    return attributes;
}

@end
