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
    double angle;
    float steadyScale;
    float scaleDelta;
    NSTimer *scaleTimer;
    BOOL labelAnimationStarted;
    
    int indexOfGargedBullet;
    
    AVAudioPlayer *loadBulletAudioPlayer;
    __weak IBOutlet UIView *vBackLightDrum;
}
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *colectionBullets;
@property (weak, nonatomic) IBOutlet UIView *vLoadGun;
@property (weak, nonatomic) IBOutlet UILabel *lbLoadGun;
@property (weak, nonatomic) IBOutlet UIView *drumBullets;
@property (weak, nonatomic) IBOutlet UIView *gun;
@property (weak, nonatomic) IBOutlet UIImageView *gunImage;
@property (weak, nonatomic) IBOutlet UIImageView *flash;
@property (weak, nonatomic) IBOutlet UIView *hudView;
@property (weak, nonatomic) IBOutlet UIView *vOponnentAvatarWithFrame;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;


@end

//points
static CGPoint pntDumpOpen;
static const CGPoint pntDumpClose = {187,128};//center of image
static const CGPoint pntGunCloseSimple = {-26,224};
static const CGPoint pntGunCloseIphone5 = {-26,312};
static CGPoint pntGunClose;
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
@synthesize isCharging;
@synthesize vLoadGun;
@synthesize lbLoadGun;
@synthesize gunImage;
@synthesize flash;
@synthesize hudView;
@synthesize ivOponnentAvatar;
@synthesize vOponnentAvatarWithFrame;
@synthesize countOfBullets;
@synthesize didFinishBlock;

#pragma mark
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];

        int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
        if (iPhone5Delta>0) {
            pntGunClose = pntGunCloseIphone5;
        }else{
            pntGunClose = pntGunCloseSimple;
        }

        isCharging = NO;
       
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
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/loadBullet.mp3", [[NSBundle mainBundle] resourcePath]]];
        loadBulletAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [loadBulletAudioPlayer prepareToPlay];
        
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
        
        vBackLightDrum.clipsToBounds = YES;
        vBackLightDrum.layer.cornerRadius = 60.f;
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
    [self setVLoadGun:nil];
    [self setLbLoadGun:nil];
    [self setGunImage:nil];
    [self setFlash:nil];
    [self setHudView:nil];
    [self setIvOponnentAvatar:nil];
    [self setVOponnentAvatarWithFrame:nil];
    [self setTextView:nil];
    [self setTextLabel:nil];
    vBackLightDrum = nil;
    [super viewDidUnload];
}

-(void)releaseComponents
{
    [self viewDidUnload];
    loadBulletAudioPlayer = nil;
}

#pragma mark
-(void)openGun;
{
    [self.view.layer removeAllAnimations];
    [self hideBullets];
    hudView.alpha = 1;
    hudView.hidden = NO;
    vLoadGun.hidden = NO;
    countOfBullets = 0;
    indexOfGargedBullet = 0;
    [UIView animateWithDuration:timeOpenGun animations:^{
        gunImage.transform = CGAffineTransformMakeRotation(gunRotationAngle);
        
        drumBullets.center = pntDumpOpen;
    }completion:^(BOOL finished) {
        vBackLightDrum.hidden = NO;
        [self backLightDrumAnimation];
    }];
}

-(void)chargeBullets;
{
    if (indexOfGargedBullet<=6) {
        isCharging = YES;
        vBackLightDrum.hidden = YES;
        [UIView animateWithDuration:timeSpinDump
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             angle -= 1.25;
                             CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                             CGAffineTransform transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                             drumBullets.transform = transform;
                         } completion:^(BOOL finished) {
                             UIImageView *bullet = [colectionBullets objectAtIndex:indexOfGargedBullet];
                             bullet.hidden = NO;
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [loadBulletAudioPlayer setCurrentTime:0.f];
                                [loadBulletAudioPlayer play];
                             });
                             hudView.alpha -= 0.1;
                             
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
    CGRect frame=self.view.frame;
    frame.origin = pntViewShow;
    self.view.frame = frame;
    
    frame=gun.frame;
    frame.origin = pntGunClose;
    gun.frame = frame;
}

-(void)hideGun;
{
    [self.textView setHidden:YES];
    [UIView animateWithDuration:timeOpenDump animations:^{
        vLoadGun.hidden = YES;
        drumBullets.center= pntDumpClose;
        gunImage.transform = CGAffineTransformMakeRotation(0);
    }completion:^(BOOL finished) {
        isCharging = NO;
        [self hideBullets];
        angle = 0;
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
        CGAffineTransform transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
        drumBullets.transform = transform;

        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin.y += 50;
            gun.frame = frame;
        }completion:^(BOOL finished) {
            hudView.alpha = 0.0;
            if (didFinishBlock) {
                didFinishBlock();
            }
        }];
    }];
}

-(void)backLightDrumAnimation
{
    [UIView animateWithDuration:0.6 animations:^{
        vBackLightDrum.alpha = 0.15;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 animations:^{
            vBackLightDrum.alpha = 0.6;
        }completion:^(BOOL finished) {
            if (![vBackLightDrum isHidden]) {
                [self backLightDrumAnimation];
            }
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

-(void)lableScaleInView:(UIView*)view
{
    __weak GunDrumViewController *bself = self;
    [UIView animateWithDuration:0.35
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.15, 1.15);
                     }completion:^(BOOL complete) {
                         [bself lableScaleOutView:view];
                     }];
}

#pragma mark IBAction

- (IBAction)DrumLoadClick:(id)sender {
    if (countOfBullets<7) {
        countOfBullets++;
        if (!isCharging) {
            [self chargeBullets];
        }
    }
}

- (IBAction)tapOnView:(id)sender {
    [self lableScaleInView:vLoadGun];
}

@end
