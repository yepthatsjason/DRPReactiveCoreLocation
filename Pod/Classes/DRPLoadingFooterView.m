
#import "DRPLoadingFooterView.h"

static const CGFloat kTextLabelFontSize = 14.0;
static const CGFloat kActivityTitlePadding = 10;

@interface DRPLoadingFooterView ()
{
  UIActivityIndicatorView *_spinner;
  UIView *_topSeparatorView;
  UIView *_bottomBorderView;
  BOOL _animateSpinner;
  UILabel *_textLabel;
}
@end

@implementation DRPLoadingFooterView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _textLabel.font = [UIFont systemFontOfSize:kTextLabelFontSize];
    [self addSubview:_textLabel];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_spinner];

    _topSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _topSeparatorView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_topSeparatorView];

    [self animateActivitySpinner:NO];
  }
  return self;
}

- (void)setShowTopSeperator:(BOOL)showTopSeperator
{
  _showTopSeperator = showTopSeperator;
  _topSeparatorView.hidden = !showTopSeperator;
  [self setNeedsLayout];
}

- (void)setShowBottomSeperator:(BOOL)showBottomSeperator
{
  _showBottomSeperator = showBottomSeperator;
  _bottomBorderView.hidden = !showBottomSeperator;
  [self setNeedsLayout];
}

- (void)animateActivitySpinner:(BOOL)animateSpinner
{
  _animateSpinner = animateSpinner;
  _spinner.hidden = !animateSpinner;
  _textLabel.hidden = animateSpinner;

  if (animateSpinner) {
    [_spinner startAnimating];
  } else {
    [_spinner stopAnimating];
  }

  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGSize activitySize = [_spinner sizeThatFits:CGSizeZero];
  CGFloat maxTextWidth = CGRectGetWidth(self.bounds) - activitySize.width - kActivityTitlePadding;
  CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(maxTextWidth, CGRectGetHeight(self.bounds))];

  if (_animateSpinner) {
    _spinner.frame = CGRectMake((CGRectGetWidth(self.bounds) - activitySize.width) / 2,
                                (CGRectGetHeight(self.bounds) - activitySize.height) / 2,
                                activitySize.width,
                                activitySize.height);
  } else {
    _textLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - textSize.width) / 2,
                                      (CGRectGetHeight(self.bounds) - textSize.height) / 2,
                                      textSize.width,
                                      textSize.height);
  }
  CGFloat separatorThickness = 1.0;
  _topSeparatorView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), separatorThickness);
}

@end
