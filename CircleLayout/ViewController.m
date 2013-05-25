//
//  ViewController.m
//  CircleLayout
//
//  Created by Scott Saia on 5/25/13.
//  Copyright (c) 2013 Scott Saia. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import "CircleLayout.h"

@interface ViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSUInteger cellCount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.cellCount = 20;
    
    // add a tap gesture for adding and deleting cells
    // could do this in storyboard
    UITapGestureRecognizer *taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:taprecognizer];
    self.collectionView.collectionViewLayout = [[CircleLayout alloc] init];
    
    // other stuff here in video but I did it in storyboard
//    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
//    [self.collectionView reloadData];
//    self.collectionView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *cellLabel = ((Cell *)cell).label;
    cellLabel.text = [NSString stringWithFormat:@"%i", indexPath.item];
    return cell;
}

// tapping on a cell deletes it and tapping on background will add a cell
- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint initialPinchPoint = [sender locationInView:self.collectionView];
        NSIndexPath *tappedCellIndexPath = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
        if (tappedCellIndexPath != nil) {
            self.cellCount = self.cellCount - 1;
            // animate deletion of cell
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:tappedCellIndexPath]];
            } completion:nil];
        } else {
            self.cellCount = self.cellCount + 1;
            // animate inserting cell
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
            } completion:nil];
        }
    }
}

@end
