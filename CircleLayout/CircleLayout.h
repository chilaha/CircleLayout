//
//  CircleLayout.h
//  CircleLayout
//
//  Created by Scott Saia on 5/25/13.
//  Copyright (c) 2013 Scott Saia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLayout : UICollectionViewLayout

@property (assign, nonatomic) CGPoint center;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) NSInteger innerCellCount;
@property (assign, nonatomic) NSInteger outerCellCount;

@property (nonatomic, assign) CGPoint pressedPoint;
@property (strong, nonatomic) NSIndexPath *pressedCellIndexPath; // current cell being dragged


@end
