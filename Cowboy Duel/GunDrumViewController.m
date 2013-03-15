//
//  GunDrumViewController.m
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import "GunDrumViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AccountDataSource.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Dinamic_BackGround.h"
#import "LoginAnimatedViewController.h"

@interface GunDrumViewController ()
{
    BOOL runAnimationDump;
    int firstAnimationCount;
    int secondAnimationCount;
    int drumAnimationCount;
    double angle;
    float steadyScale;
    float scaleDelta;
    NSTimer *scaleTimer;
    BOOL labelAnimationStarted;
    
    int indexOfGargedBullet;
    
    AVAudioPlayer *putGunDownAudioPlayer;
}
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *colectionBullets;
@property (weak, nonatomic) IBOutlet UIView *vLoadGun;
@property (weak, nonatomic) IBOutlet UILabel *lbLoadGun;
@property (weak, nonatomic) IBOutlet UIView *drumBullets;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIView *gun;
@property (weak, nonatomic) IBOutlet UIImageView *gunImage;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoneImg;
@property (weak, nonatomic) IBOutlet UIImageView *flash;
@property (weak, nonatomic) IBOutlet UIView *hudView;
@property (weak, nonatomic) IBOutlet UIView *vOponnentAvatarWithFrame;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;


@end

//points
static CGPoint pntDumpOpen;
static const CGPoint pntDumpClose = {187,128};//center of image
static CGPoint pntGunOpen;
static const CGPoint pntGunClose = {-26,224};
static const CGPoint pntGunHide = {-26,400};
static const CGPoint pntViewShow = {0,0};
static const CGPoint pntViewHide = {0,400};

//angle
static const CGFloat gunRotationAngle = M_2_PI / 2;

//Time
static const CGFloat timeOpenGun = 0.4f;
static const CGFloat timeOpenDump = 0.4f;
static const CGFloat timeCloseGun = 0.2f;
static const CGFloat timeChargeBullets = 0.5f;
static const CGFloat timeSpinDump = 0.3f;


@implementation GunDrumViewController
@synthesize colectionBullets;
@synthesize drumBullets;
@synthesize gun;
@synthesize arrow;
@synthesize isCharging;
@synthesize vLoadGun;
@synthesize lbLoadGun;
@synthesize gunImage;
@synthesize ivPhoneImg;
@synthesize flash;
@synthesize hudView;
@synthesize ivOponnentAvatar;
@synthesize vOponnentAvatarWithFrame;
@synthesize countOfBullets;

#pragma mark
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];

        isCharging = NO;
        
        pntGunOpen=gun.frame.origin;
        pntDumpOpen=drumBullets.center;
        
        CGRect frame=gun.frame;
        frame.origin = pntGunClose;
        gun.frame = frame;
        
        gunImage.layer.anchorPoint = CGPointMake(0.5, 1);
        frame = gunImage.frame;
        frame.origin.y += frame.size.height / 2;
        gunImage.frame = frame;
        drumBullets.center= pntDumpClose;
        
        frame=self.view.frame;
        frame.origin = pntViewHide;
        self.view.frame = frame;
        
        lbLoadGun.text = NSLocalizedString(@"Load", @"");
        steadyScale = 1.0;
        scaleDelta = 0.0;
        
        NSError *error;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/follSound.aif", [[NSBundle mainBundle] resourcePath]]];
        putGunDownAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [putGunDownAudioPlayer prepareToPlay];
        
        [self helpAnimation];
        vOponnentAvatarWithFrame.hidden = YES;
        
        
        if([LoginAnimatedViewController sharedInstance].isDemoPractice){
            [self.textView setDinamicHeightBackground];
            [self.textLabel setText:NSLocalizedString(@"LoadPractice", @"")];
            [self.textView setHidden:NO];
            [self.textLabel setHidden:NO];
            [self performSelector:@selector(textViewSetHidden) withObject:nil afterDelay:5.0];
        }else
        {
            [self textViewSetHidden];
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDrumBullets:nil];
    [self setColectionBullets:nil];
    [self setArrow:nil];
    [self setVLoadGun:nil];
    [self setLbLoadGun:nil];
    [self setGunImage:nil];
    [self setTapRecognizer:nil];
    [self setIvPhoneImg:nil];
    [self setFlash:nil];
    [self setHudView:nil];
    [self setIvOponnentAvatar:nil];
    [self setVOponnentAvatarWithFrame:nil];
    [self setTextView:nil];
    [self setTextLabel:nil];
    [super viewDidUnload];
}

-(void)releaseComponents
{
    [self viewDidUnload];
    putGunDownAudioPlayer = nil;
}

#pragma mark
-(void)openGun;
{
    [self.view.layer removeAllAnimations];
    [self hideBullets];
    [UIView animateWithDuration:timeOpenGun animations:^{
        arrow.hidden = YES;
        ivPhoneImg.hidden = YES;
        gunImage.transform = CGAffineTransformMakeRotation(gunRotationAngle);
        
        drumBullets.center = pntDumpOpen;
    }completion:^(BOOL finished) {
    }];
}

-(void)closeDump;
{
    isCharging = NO;
    
    [UIView animateWithDuration:timeOpenDump animations:^{
        drumBullets.center= pntDumpClose;
        gunImage.transform = CGAffineTransformMakeRotation(0);
        runAnimationDump = NO;
    }completion:^(BOOL finished) {
        isCharging = NO;
        [self hideBullets];
        
        arrow.hidden = NO;
        ivPhoneImg.hidden = NO;
        hudView.alpha = 0.7f;
        vOponnentAvatarWithFrame.hidden = YES;
        [self changeLableAnimation:vLoadGun endReverce:YES toText:NSLocalizedString(@"Load", @"")];
        angle = 0;
        CGAffineTransform transform = drumBullets.transform;
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
        transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
        drumBullets.transform = transform;
        
        [putGunDownAudioPlayer setCurrentTime:0.0];
        [putGunDownAudioPlayer play];
        
        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin = pntGunClose;
            gun.frame = frame;
        }completion:^(BOOL finished) {
        }];
    }];
}

-(void)chargeBullets;
{
    if (indexOfGargedBullet<=6) {
        isCharging = YES;
        [UIView animateWithDuration:timeSpinDump
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             angle -= 1.25;
                             CGAffineTransform transform = drumBullets.transform;
                             CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                             transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                             drumBullets.transform = transform;
                         } completion:^(BOOL finished) {
                             UIImageView *bullet = [colectionBullets objectAtIndex:indexOfGargedBullet];
                             bullet.hidden = NO;
                             indexOfGargedBullet++;
                             if ((countOfBullets - indexOfGargedBullet)==0) {
                                 isCharging = NO;
                                 if (countOfBullets==7) {
                                     [self hideGun];
                                 }
                             }else{
                                 [self chargeBullets];
                             }
                         }];
    }
}

-(void)hideBullets
{
    vOponnentAvatarWithFrame.hidden = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (UIImageView *bullet in colectionBullets) {
            dispatch_async(dispatch_get_main_queue(), ^{
                bullet.hidden = YES;
            });
        }
    });
}

-(void)showGun;
{
    hudView.alpha = 0.7f;
    
    CGRect frame=self.view.frame;
    frame.origin = pntViewShow;
    self.view.frame = frame;
}

-(void)hideGun;
{
    [self.textView setHidden:YES];
    [UIView animateWithDuration:timeOpenDump animations:^{
        vLoadGun.hidden = YES;
        drumBullets.center= pntDumpClose;
        gunImage.transform = CGAffineTransformMakeRotation(0);
        runAnimationDump = NO;
    }completion:^(BOOL finished) {
        isCharging = NO;
        [self hideBullets];
        angle = 0;
        CGAffineTransform transform = drumBullets.transform;
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
        transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
        drumBullets.transform = transform;

        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin.y += 50;
            gun.frame = frame;
        }completion:^(BOOL finished) {
        }];
    }];
}

#pragma mark

-(void)closeController;
{
    [self.view removeFromSuperview];
    [scaleTimer invalidate];
}

-(void)setScale
{
    if (steadyScale >= 1.3) scaleDelta = -0.01;
    if (steadyScale <= 1.0) scaleDelta = 0.02;
    steadyScale += scaleDelta;
}

-(void)helpAnimation{

    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"ivIphoneImg1.png"],
                         [UIImage imageNamed:@"ivIphoneImg2.png"],
                         nil];
    ivPhoneImg.animationImages = imgArray;
    ivPhoneImg.animationDuration = 2.0f;
    [ivPhoneImg setAnimationRepeatCount:0];
    [ivPhoneImg startAnimating];
   
}

-(void)lableScaleOutView:(UIView*)view
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }completion:^(BOOL complete) {
                     }];
    
}

-(void)changeLableAnimation:(UIView*)view endReverce:(BOOL)reverce toText:(NSString *)text
{
    if(labelAnimationStarted) return;
    labelAnimationStarted = YES;
    CGRect startFrame = view.frame;
    float duration;
    if (self.textView.isHidden) duration = 0.35;
    else duration = 0;
        
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect frame = view.frame;
                         if (reverce) frame.origin.x = -400;
                         else frame.origin.x = 400;
                         view.frame = frame;
                     }completion:^(BOOL complete) {
                         [view setHidden:YES];
                         CGRect frame = view.frame;
                         if (reverce) frame.origin.x = frame.size.width;
                         else frame.origin.x = -frame.size.width;
                         view.frame = frame;
                         [view setHidden:NO];
                         lbLoadGun.text = text;
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              view.frame = startFrame;
                                          }completion:^(BOOL complete) {
                                              labelAnimationStarted = NO;
                                          }];
                     }];
}

-(void)showLableWithText:(NSString *)text
{
    
}

-(void)shotAnimation;
{
    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"gd_gun.png"],
                         [UIImage imageNamed:@"gd_gunShot.png"],
                         nil];
    gunImage.animationImages = imgArray;
    gunImage.animationDuration = 0.18f;
    [gunImage setAnimationRepeatCount:1];
    [gunImage startAnimating];
    
    [UIView animateWithDuration:0.13 delay:0.09 options:UIViewAnimationOptionTransitionNone animations:^{
        gun.transform = CGAffineTransformMakeTranslation(0, 8);
    } completion:^(BOOL complete) {
        gun.transform = CGAffineTransformMakeTranslation(0, -8);
    }];
    
    flash.alpha = 0.f;
    flash.hidden = NO;
    [UIView animateWithDuration:0.18 animations:^{
        flash.alpha = 1.0;
        flash.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL complete) {
        flash.hidden = YES;
        flash.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

-(void)displayHubView;
{
    [UIView animateWithDuration:1.f animations:^{
        hudView.alpha = 0.0;
    } completion:^(BOOL complete) {
    }];
}

-(void)textViewSetHidden
{
    [self.textView setHidden:YES];
    [self.textLabel setHidden:YES];
}

#pragma mark Responding to gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((gestureRecognizer == self.tapRecognizer)&&(!vLoadGun.isHidden)) {
        return YES;
    }
    return NO;
}
- (IBAction)tapOnView:(id)sender {
    if (countOfBullets<7) {
        countOfBullets++;
        if (!isCharging) {
            [self chargeBullets];
        }
    }
}

@end
