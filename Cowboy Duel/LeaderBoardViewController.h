//
//  LeaderBoardViewController.h
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 11.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
////NSString *const URL_LEADER_BOARD=@"http://apachan.net/thumbs/201008/24/o1tgo3x71jxm.jpg";
#define URL_LEADER_BOARD @"http://m.platforma.webkate.com/app/?id=420"

@interface LeaderBoardViewController : UIViewController 
{
    
    IBOutlet UIView *leadMainView;
    IBOutlet UIWebView *leaderboardWebView;
}
- (IBAction)exitLeaderBoard:(id)sender;
@end
