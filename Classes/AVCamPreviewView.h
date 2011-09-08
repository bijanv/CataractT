#import <UIKit/UIKit.h>

@protocol AVCamPreviewViewDelegate
@optional
- (void)tapToFocus:(CGPoint)point;
- (void)tapToExpose:(CGPoint)point;
- (void)resetFocusAndExpose;
-(void)cycleGravity;
@end

@interface AVCamPreviewView : UIView {
    id <AVCamPreviewViewDelegate> _delegate;
}

@property (nonatomic,retain) IBOutlet id <AVCamPreviewViewDelegate> delegate;

@end
