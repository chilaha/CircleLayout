//
//  CViewController.m
//  CircleLayout
//
//  Created by Scott Saia on 1/20/14.
//  Copyright (c) 2014 Scott Saia. All rights reserved.
//

#import "CViewController.h"
#import "Cell.h"
#import "CircleLayout.h"

@interface CViewController () <UICollectionViewDataSource>

@property (nonatomic) NSUInteger innerCellCount;
@property (nonatomic) NSUInteger outerCellCount;
@property (weak, nonatomic) IBOutlet CircleLayout *circleLayout;

@end

@implementation CViewController

- (void)viewDidLoad
{
    self.outerCellCount = 20; // section 0
    self.innerCellCount = 10; // section 1
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.outerCellCount;
    }
    return self.innerCellCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *cellLabel = ((Cell *)cell).label;
    cellLabel.text = [NSString stringWithFormat:@"%i", indexPath.item];
    return cell;
}



#pragma mark - Gesture Recognizers

// longPress picks up cell and allows dragging around
// dropping cell on another moves it to the cell below position
- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) { // when press begins

        CGPoint initialPressPoint = [sender locationInView:self.collectionView];
        NSIndexPath *pressedCellIndexPath = [self.collectionView indexPathForItemAtPoint:initialPressPoint];

        if (pressedCellIndexPath) {
            [self.collectionView performBatchUpdates:^{
                self.circleLayout.pressedCellIndexPath = pressedCellIndexPath;
                self.circleLayout.pressedPoint = initialPressPoint;
            }completion:nil];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) { // when press changes
        
        CGPoint currentPressPoint = [sender locationInView:self.collectionView];
        self.circleLayout.pressedPoint = currentPressPoint; // tell layout new point
        
    } else if (sender.state == UIGestureRecognizerStateEnded) { // when press ends
        
        CGPoint lastPressPoint = [sender locationInView:self.collectionView];
        UICollectionViewCell *currentPressedCell = [self.collectionView cellForItemAtIndexPath:self.circleLayout.pressedCellIndexPath];
        // can't use indexPathForItemAtPoint: since it will always return pressedCellIndexPath
        // iterate though visible cells and find the cell below lastPresPoint
        NSIndexPath *cellBelowIndexPath;
        for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
            if (CGRectContainsPoint(cell.frame, lastPressPoint) && cell != currentPressedCell) {
                cellBelowIndexPath = [self.collectionView indexPathForCell:cell];
            }
        }
        if (cellBelowIndexPath) { // if found a cell below hovering snap shot
            NSIndexPath *pressedCellIndexPath = self.circleLayout.pressedCellIndexPath;
            // if pressedCell and cellBelow not in same section - adjust section counts
            if (pressedCellIndexPath.section != cellBelowIndexPath.section) {
                if (pressedCellIndexPath.section == 0) {
                    self.innerCellCount++;
                    self.outerCellCount--;
                } else {
                    self.innerCellCount--;
                    self.outerCellCount++;
                }
            }
            [self.collectionView performBatchUpdates:^{
                [self.collectionView moveItemAtIndexPath:self.circleLayout.pressedCellIndexPath toIndexPath:cellBelowIndexPath];
            } completion:nil];
        }
        self.circleLayout.pressedCellIndexPath = nil;
        
    } else if (sender.state == UIGestureRecognizerStateCancelled || // when press cancels or ends
               sender.state == UIGestureRecognizerStateFailed) {
        self.circleLayout.pressedCellIndexPath = nil;
    }
}




// tapping on a cell deletes it and tapping on background will add a cell
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint initialPinchPoint = [sender locationInView:self.collectionView];
        NSIndexPath *tappedCellIndexPath = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
        if (tappedCellIndexPath != nil) {
            // animate deletion of cell
            if (tappedCellIndexPath.section == 0) {
                self.outerCellCount--;
            } else {
                self.innerCellCount--;
            }
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:tappedCellIndexPath]];
            } completion:nil];
        } else {
            self.outerCellCount = self.outerCellCount + 1;
            // animate inserting cell
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
            } completion:nil];
        }
    }
}

@end
