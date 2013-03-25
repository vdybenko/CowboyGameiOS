//
//  ArrowToOpponent.m
//  Bounty Hunter
//
//  Created by Taras on 20.03.13.
//
//

#import "ArrowToOpponent.h"
#import <QuartzCore/QuartzCore.h>
@interface ArrowToOpponent()
{
    IBOutlet UIView *mainSubView;
    __weak IBOutlet UIImageView *leftArrow;
    __weak IBOutlet UIImageView *rightArrow;
    __weak IBOutlet UIView *vBackIcon;
    
}
@end;
@implementation ArrowToOpponent
@synthesize ivOpponent;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        @autoreleasepool {
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ArrowToOpponent" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        }
        
        CGAffineTransform transformMirror = CGAffineTransformMakeScale(-1.0, 1.0);
        leftArrow.transform = transformMirror;
        
        CGRect cropRect = CGRectMake(95, 0, 140, 140);
        CGImageRef subImageRef = CGImageCreateWithImageInRect([[UIImage imageNamed:@"men_low.png"] CGImage], cropRect);
        CGRect smallBounds = CGRectMake(cropRect.origin.x, cropRect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
        
        UIGraphicsBeginImageContext(smallBounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, smallBounds, subImageRef);
        UIImage* smallImg = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        
        [ivOpponent setImage:smallImg];
        
        vBackIcon.clipsToBounds = YES;
        vBackIcon.layer.cornerRadius = ivOpponent.frame.size.width/2;
        
        ivOpponent.clipsToBounds = YES;
        ivOpponent.layer.cornerRadius = ivOpponent.frame.size.width/2;
    }
    return self;
}

-(void)releaseComponents
{
    UIView *firstView = [self.subviews objectAtIndex:0];
    firstView = nil;
    mainSubView = nil;
    leftArrow = nil;
    rightArrow = nil;
    ivOpponent = nil;
}

#pragma mark

- (void) setDirection:(ArrowToOpponentDirection)direction;
{
    switch (direction) {
        case ArrowToOpponentDirectionLeft:
            mainSubView.hidden = NO;
            rightArrow.hidden = YES;
            leftArrow.hidden = NO;
            break;
        case ArrowToOpponentDirectionRight:
            mainSubView.hidden = NO;
            rightArrow.hidden = NO;
            leftArrow.hidden = YES;
            break;
        case ArrowToOpponentDirectionCenter:
            mainSubView.hidden = YES;
            break;
        default:
            break;
    }
}

- (void) updateRelateveToView:(UIView*)view mainView:(UIView*)mainView;
{
    CGRect frame = [[view superview] convertRect:view.frame toView:mainView];
    CGRect winRect = [UIScreen mainScreen].bounds;
    if (CGRectIntersectsRect(winRect, frame)) {
        [self setDirection:ArrowToOpponentDirectionCenter];
    }else{
        float xNew;
        float yNew  = frame.origin.y + (frame.size.height/2);
        if (yNew<0) {
            yNew = 0;
        }else if ((yNew+self.frame.size.height)>winRect.size.height){
            yNew = winRect.size.height - self.frame.size.height;
        }
        if (frame.origin.x < 0) {
            xNew = 0;
            [self setDirection:ArrowToOpponentDirectionLeft];
        }else{
            xNew = winRect.size.width - self.frame.size.width;
            [self setDirection:ArrowToOpponentDirectionRight];
        }
        CGRect frame = self.frame;
        frame.origin = (CGPoint){xNew,yNew};
        self.frame = frame;
    }
}

@end
