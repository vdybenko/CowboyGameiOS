//
//  DuelDataSource.m
//  Test
//
//  Created by Sobol on 27.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelDataSource.h"
#import "JSON.h"
#import "Utils.h"
#import "CustomNSURLConnection.h"


@implementation DuelDataSource

static const char *AUTHENTICATE_URL = BASE_URL "/api/authorization";
static const char *GET_SESSION_URL = BASE_URL "/api/session";
static const NSString *md5SharedSecret = @"uWW4fCpfsuuL6t8sewy0RJOXJ6Sogtte";

@synthesize isAuthenticated, lastRequest;


-(id)initWithLogin:(GKLocalPlayer *)localPlayer;
{
    NSLog(@"Init");
    playerAccount = [[AccountDataSource alloc] initWithLocalPlayer];
                     return self;
}

#pragma mark -
#pragma mark Memory management



#pragma mark -
#pragma mark Authenticate method 

- (void)authenticate {
	
	isAuthenticated = NO;
	
	if (lastRequest)
		return;
	
    NSString *gcUserId = playerAccount.accountName;
    
    if ([gcUserId length] == 0)
        gcUserId = @"Anonymous";
	    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:AUTHENTICATE_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           gcUserId,@"authentification",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
//        [receivedData setLength:0];
        receivedData = [[NSMutableData alloc] init];
    } else {
    }
    
    lastRequest = theRequest;
}


#pragma mark -
#pragma mark Private methods

- (void)sendResponseWithChallangeValue:(NSString *)cValue {
	
	NSString *authToken = [md5SharedSecret stringByAppendingString:cValue];
    NSString *response =[Utils md5:authToken];
	
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:GET_SESSION_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                           response,@"string",
                           nil];
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
//        [receivedData setLength:0];
        receivedData = [[NSMutableData alloc] init];
    } else {
    }
	lastRequest = theRequest;
	
}


#pragma mark -

#pragma mark CustomNSURLConnection handlers


- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    
	NSString *challengeValue = ValidateObject([responseObject objectForKey:@"rand_string"], [NSString class]);
    
	NSDictionary *session = ValidateObject([responseObject objectForKey:@"session"], [NSDictionary class]);
    NSNumber *err_code = ValidateObject([session objectForKey:@"err_code"], [NSNumber class]);
        
    lastRequest = nil;
    
	if ([challengeValue length] > 0) {
		[self sendResponseWithChallangeValue:challengeValue];
	} else if ([err_code intValue] == 1) {
        
        lastRequest = nil;
        
        isAuthenticated = YES;
        
        
	}
	
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    lastRequest = nil;
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end



NSString *const AuthenticatedNotification = @"AuthenticatedNotification";

