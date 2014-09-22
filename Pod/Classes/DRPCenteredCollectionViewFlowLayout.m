#import "DRPCenteredCollectionViewFlowLayout.h"


@implementation DRPCenteredCollectionViewFlowLayout

- (CGSize)collectionViewContentSize
{
  NSInteger cardCount = [self _totalCardCount];
  CGSize contentSize = CGSizeMake((cardCount * self.cardSize.width) + ((cardCount - 1) * self.cardInterimSpacing) + self.cardInset.left + self.cardInset.right, self.cardSize.height + self.cardInset.top + self.cardInset.bottom);

  // NOTE: This hack is needed to handle edge case where the single card with insets, fits exact width of collection view frame.
  // In this case scroll view wont scroll as content size is less than or equal to collection view frame. This results in
  // the snap animation not working correctly further resulting in entity cards not able to load additional cards in case
  // there is only single card visible initially. The following fix is to workaround that problem and atleast have contentsize
  // one pixel more so that scroll view always scrolls allowing us to load additional cards and show right animation.
  if (cardCount == 1 && contentSize.width <= CGRectGetWidth(self.collectionView.frame)) {
    contentSize.width = CGRectGetWidth(self.collectionView.frame) + 1;
  }

  return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  CGFloat cardWidthWithSpacing = self.cardSize.width + self.cardInterimSpacing;
  int cardsToSkip = MAX(floor(rect.origin.x / cardWidthWithSpacing), 0);

  // Get all card index ranges and find out the section the index maps to
  NSArray *sectionRanges = [self _sectionRanges];
  NSInteger sectionForCardIndex = NSNotFound;
  NSRange sectionRangeForCardIndex = NSMakeRange(0,0);
  NSInteger cardCount = [self _totalCardCount];
  NSMutableArray *layoutAttributes = [NSMutableArray array];
  for (NSInteger cardIndex = cardsToSkip; cardIndex < cardCount; cardIndex++) {
    if (!NSLocationInRange(cardIndex, sectionRangeForCardIndex)) {
      sectionForCardIndex = [self _sectionForCardIndex:cardIndex sectionRanges:sectionRanges];
      if (sectionForCardIndex != NSNotFound) {
        sectionRangeForCardIndex = [[sectionRanges objectAtIndex:sectionForCardIndex] rangeValue];
      } else {
        break;
      }
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(cardIndex - sectionRangeForCardIndex.location) inSection:sectionForCardIndex];
    UICollectionViewLayoutAttributes *layoutAttributesForCard = [self layoutAttributesForItemAtIndexPath:indexPath];
    if (CGRectIntersectsRect(rect, layoutAttributesForCard.frame)) {
      [layoutAttributes addObject:layoutAttributesForCard];
    } else {
      break;
    }
  }

  return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

  NSUInteger cardIndex = [self _cardIndexForIndexPath:indexPath];

  if (self.fullscreenCardIndexPath) {
    layoutAttributes.frame = CGRectMake(cardIndex * self.fullScreenSize.width, 0, self.fullScreenSize.width, self.fullScreenSize.height);
    layoutAttributes.bounds = CGRectMake(0, 0, self.fullScreenSize.width, self.fullScreenSize.height);
  } else {
    layoutAttributes.frame = CGRectMake((cardIndex * (self.cardInterimSpacing + self.cardSize.width)) + self.cardInset.left, self.cardInset.top, self.cardSize.width, self.cardSize.height);
    layoutAttributes.bounds = CGRectMake(0, 0, self.cardSize.width, self.cardSize.height);
  }
  return layoutAttributes;
}

- (NSUInteger)_cardIndexForIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger cardIndex = indexPath.row;
  for (NSUInteger section = 0; section < indexPath.section; section += 1) {
    cardIndex += [self.collectionView numberOfItemsInSection:section];
  }

  return cardIndex;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  return YES;
}

// This function allows us to snap cards in the middle of the screen.
// When scrolling right or left, we simply ensure that the offset is adjusted so that midpoint of next or previous card is snapped to center of screen
// Left and right cards are always snapped to max and min extent
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
  if (self.collectionView.pagingEnabled || self.fullscreenCardIndexPath) {
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
  }

  // For smooth scrolling we need the following logic
  CGFloat proposedMidPoint = proposedContentOffset.x + CGRectGetWidth(self.collectionView.bounds) / 2;
  NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:CGRectMake(proposedContentOffset.x, proposedContentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds))];

  UICollectionViewLayoutAttributes *cardLayoutToSnap = nil;
  if (velocity.x > 0) {   // Going right
    for (UICollectionViewLayoutAttributes *cardLayoutAttributes in layoutAttributes) {
      if (cardLayoutAttributes.center.x >= proposedMidPoint) {
        cardLayoutToSnap = cardLayoutAttributes;
        break;
      }
    }
  } else if (velocity.x < 0) { // Going left
    for (UICollectionViewLayoutAttributes *cardLayoutAttributes in layoutAttributes.reverseObjectEnumerator) {
      if (cardLayoutAttributes.center.x <= proposedMidPoint) {
        cardLayoutToSnap = cardLayoutAttributes;
        break;
      }
    }
  } else { // For no velocity we snap to closest midpoint
    CGFloat distance = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *cardLayoutAttributes in layoutAttributes) {
      CGFloat newdistance = fabsf(proposedMidPoint - cardLayoutAttributes.center.x);
      if (newdistance < distance) {
        distance = newdistance;
        cardLayoutToSnap = cardLayoutAttributes;
      }
    }
  }

  if (cardLayoutToSnap) {
    // Snap target offset to mix and max possible values, failure to do so will mess up the layout and cards wont snap to middle of the screen anymore
    return [self _snapToContentSizeWithOffset:CGPointMake(cardLayoutToSnap.center.x - CGRectGetWidth(self.collectionView.bounds) / 2, 0)];
  } else {
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
  }
}

- (CGPoint)targetContentOffsetForProposedCardAtIndexPath:(NSIndexPath *)cardIndexPath
{
  if (self.fullscreenCardIndexPath) {
    return CGPointMake([self _cardIndexForIndexPath:cardIndexPath ] * self.fullScreenSize.width, 0);
  }

  UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:cardIndexPath];
  return [self _snapToContentSizeWithOffset:CGPointMake(layoutAttributes.center.x - CGRectGetWidth(self.collectionView.bounds) / 2, 0)];
}

- (CGPoint)snapToPageWithProposedContentOffset:(CGPoint)contentOffset
{
  CGRect visibleRect = CGRectMake(contentOffset.x, contentOffset.y, CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
  NSArray *visiblePagesLayoutAttributes = [self layoutAttributesForElementsInRect:visibleRect];
  for (UICollectionViewLayoutAttributes *visiblePageLayoutAttribute in visiblePagesLayoutAttributes) {
    if (contentOffset.x < visiblePageLayoutAttribute.center.x) {
      contentOffset = [self _snapToContentSizeWithOffset:CGPointMake(visiblePageLayoutAttribute.center.x - CGRectGetWidth(self.collectionView.frame) / 2, contentOffset.y)];
      break;
    }
  }

  return contentOffset;
}

#pragma -
#pragma Helpers
// Makes sure content offset always stays within 0 to contentsize
- (CGPoint)_snapToContentSizeWithOffset:(CGPoint)contentOffset
{
  contentOffset.x = MIN(MAX(contentOffset.x, 0), self.collectionViewContentSize.width - CGRectGetWidth(self.collectionView.bounds));
  contentOffset.y = MIN(MAX(contentOffset.y, 0), self.collectionViewContentSize.height);
  return contentOffset;
}

// Returns total number of cards across sections
- (NSUInteger)_totalCardCount
{
  NSUInteger cardCount = 0;
  for (NSUInteger section = 0; section < self.collectionView.numberOfSections; section++) {
    cardCount += [self.collectionView numberOfItemsInSection:section];
  }
  return cardCount;
}

// Returns the card ranges in sections. i.e. left load indicators, cards, right load indicators
- (NSArray *)_sectionRanges
{
  NSMutableArray *sectionRanges = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
  NSUInteger cardIndex = 0;
  for (NSUInteger section = 0; section < self.collectionView.numberOfSections; section++) {
    NSUInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
    [sectionRanges addObject:[NSValue valueWithRange:NSMakeRange(cardIndex, itemsInSection)]];
    cardIndex += itemsInSection;
  }

  return sectionRanges;
}

- (NSInteger)_sectionForCardIndex:(NSUInteger)cardIndex sectionRanges:(NSArray *)sectionRanges
{
  for (NSUInteger section = 0; section < sectionRanges.count; section++) {
    NSRange sectionIndexRange = [[sectionRanges objectAtIndex:section] rangeValue];
    if (NSLocationInRange(cardIndex, sectionIndexRange)) {
      return section;
    }
  }

  return NSNotFound;
}

@end
