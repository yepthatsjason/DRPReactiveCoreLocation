//
//  DRPCenteredCollectionViewFlowLayout.h
//  Comment Box
//
//  Created by Jason Ederle on 9/14/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRPCenteredCollectionViewFlowLayout : UICollectionViewLayout
@property (nonatomic, assign) CGFloat cardInterimSpacing;
@property (nonatomic, assign) UIEdgeInsets cardInset;
@property (nonatomic, assign) CGSize cardSize;
@property (nonatomic, assign) CGSize fullScreenSize;
@property (nonatomic, copy) NSIndexPath *fullscreenCardIndexPath;

- (CGPoint)targetContentOffsetForProposedCardAtIndexPath:(NSIndexPath *)cardIndex;

- (CGPoint)snapToPageWithProposedContentOffset:(CGPoint)contentOffset;

@end
