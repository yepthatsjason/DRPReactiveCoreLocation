
#import <UIKit/UIKit.h>

@protocol DRPFaceViewDelegate;

@interface DRPFaceView : UIView
@property (weak, nonatomic) id<DRPFaceViewDelegate> delegate;
@property (readonly, nonatomic) UIButton *button;
@end
