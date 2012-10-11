//
//  SwitchCell.h
//  CustomCell
//
//  Created by Aliksandr Andrashuk on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCell : UITableViewCell
{
    IBOutlet UILabel *m_label;
    IBOutlet UISwitch *m_state;
}

@property (nonatomic, readonly) UILabel* label;
@property (nonatomic, readonly) UISwitch* state;

+(SwitchCell*)cell;
+(NSString*) cellID;

@end
