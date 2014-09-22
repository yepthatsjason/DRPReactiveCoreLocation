#import <UIKit/UIKit.h>

// Shows a loading spinner when animating, else it shows center aligned text label
@interface DRPLoadingFooterView : UITableView
@property (nonatomic) BOOL showTopSeperator;
@property (nonatomic) BOOL showBottomSeperator;

// If YES, show and animate the activity spinner
- (void)animateActivitySpinner:(BOOL)animateSpinner;

@end
