//
//  LoginAnimatedViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 07.11.12.
//
//

#import "LoginAnimatedViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "BEAnimationView.h"

@interface LoginAnimatedViewController ()
@property (nonatomic) int textIndex;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSArray *textsContainer;
@property (nonatomic) AVAudioPlayer *player;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *payButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *animetedText;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *loginFBbutton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *tryAgainView;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *guillotineImage;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *whiskersImage;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *heatImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *headImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *noseImage;
@end

@implementation LoginAnimatedViewController
@synthesize timer, textsContainer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        textsContainer = [NSArray arrayWithObjects:@"First loooong text", @"Second loooong text", @"Third loooong text", @"Forth loooong text", @"Fifth loooong text", @"Six loooong text", nil];
        self.textIndex = 0;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kassa.aif", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [self.player setVolume:1.0];
        [self.player prepareToPlay];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateLabels];
    [self.guillotineImage animateWithType:[NSNumber numberWithInt:GUILLOTINE]];
    [self.whiskersImage animateWithType:[NSNumber numberWithInt:WHISKERS]];
    [self.heatImage animateWithType:[NSNumber numberWithInt:HAT]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabels
{
    NSString * text = [textsContainer objectAtIndex:self.textIndex];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                        [self lableScaleOut];
                     } completion:^(BOOL complete) {
                         self.animetedText.text = text;
                         [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
                     }];
}

-(void)lableScaleIn
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.animetedText.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL complete) {
                         [self.player setCurrentTime:0];
                         [self.player play];
                         if (self.textIndex<5){
                             self.textIndex++;
                             if (self.textIndex==2) {
                                 [self scaleButton:self.payButton];
                                 return;
                             }
                             if (self.textIndex==5) {
                                 [self.headImage setHidden:YES];
                                 [self.heatImage setHidden:NO];
                                 [self.noseImage setHidden:YES];
                                 [self.whiskersImage setHidden:YES];
                                 [self scaleButton:self.loginFBbutton];
                                 return;
                             }
                             [self performSelector:@selector(updateLabels) withObject:nil afterDelay:2.0];
                             
                         }
                         else {
                             [self.guillotineImage animateWithType:[NSNumber numberWithInt:FALL]];
                             [self.heatImage performSelector:@selector(animateWithType:) withObject:[NSNumber numberWithInt:FALL] afterDelay:0.2];
                             [self performSelector:@selector(showTryAgain) withObject:nil afterDelay:0.7];
                         }
                     }];
}

-(void)lableScaleOut
{
    self.animetedText.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

-(void)scaleButton:(UIButton *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.5 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
            [self updateLabels];
        } ];
        
    }];
}

-(void)showTryAgain
{
    [self.heatImage setHidden:YES];
    [self.tryAgainView setHidden:NO];
}

- (IBAction)tryAgainButtonClick:(id)sender
{
    CGRect frame = self.guillotineImage.frame;
    frame.origin.y = -310;
    self.guillotineImage.frame = frame;
    frame = self.heatImage.frame;
    frame.origin.y -= 220;
    self.heatImage.frame = frame;
    [self.noseImage setHidden:NO];
    [self.tryAgainView setHidden:YES];
    [self.headImage setHidden:NO];
    [self.whiskersImage setHidden:NO];
    self.textIndex = 0;
    [self updateLabels];
    [self.guillotineImage animateWithType:[NSNumber numberWithInt:GUILLOTINE]];
}

- (void)viewDidUnload {
    [self setAnimetedText:nil];
    [self setPayButton:nil];
    [self setLoginFBbutton:nil];
    [self setTryAgainView:nil];
    [self setGuillotineImage:nil];
    [self setWhiskersImage:nil];
    [self setHeatImage:nil];
    [self setHeadImage:nil];
    [self setNoseImage:nil];
    [super viewDidUnload];
}
@end
