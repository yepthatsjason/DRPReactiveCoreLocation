#import "DRPFaceView.h"

@interface DRPFaceView ()
@property (readwrite, nonatomic) CGFloat cornerRadius;
@end

@implementation DRPFaceView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // button that holds face image
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_button];
    self.clipsToBounds = YES;
  }
  return self;
}

// maintain circular mask on frame changes
- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  [self.layer setCornerRadius:frame.size.width/2];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
  self.layer.cornerRadius = _cornerRadius;
  [self setNeedsDisplay];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _button.frame = self.bounds;
}

@end
