//
//  ProfileImageView.h
//  Cowboy Duel
//
//  Created by Sergey Sobol on 01.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileImageView : UIImageView
{
    id __unsafe_unretained delegate;
}
@property ( unsafe_unretained, readwrite)id delegate;
@end
