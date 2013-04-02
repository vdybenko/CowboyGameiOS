//
//  SSConnection.m
//  TCPClient
//
//  Created by Sergey Sobol on 11.10.12.
//  Copyright (c) 2012 Sergey Sobol. All rights reserved.
//

#import "SSConnection.h"
#import "AccountDataSource.h"
#import "ListOfItemsViewController.h"


@interface SSConnection ()
{
    BOOL blockResponceListOnLine;
}
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) NSTimer *pingTimer;
@property (nonatomic) BOOL firstPing;

@end


static SSConnection *connection;

@implementation SSConnection

@synthesize inputStream, outputStream, firstPing, pingTimer, delegate, gameCenterViewController, connectionOpen;

+(id)sharedInstance
{
    if (!connection) {
        connection = [[SSConnection alloc] init];
    }
    return connection;
}

- (void)networkCommunicationWithPort:(NSString *)port andIp:(NSString *)ip {
    //if(self.outputStream && (self.outputStream.streamStatus != NSStreamStatusClosed)) return;
    if (connectionOpen) {
        [connection sendData:@"" packetID:NETWORK_SET_AVIBLE ofLength:sizeof(int)];
        [self sendInfoPacket];
        return;
    }
    self.firstPing = YES;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, [port intValue], &readStream, &writeStream);
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendKeepAlive) userInfo:nil repeats:YES];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
            connectionOpen = YES;
            break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[4096];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [self getData:buffer andLength:len];
                    }
                }
            }
			break;
            
		case NSStreamEventErrorOccurred:
            connectionOpen = NO;
            [self.inputStream close];
            [self.outputStream close];
            
			NSLog(@"Can not connect to the host!");
            
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:{
            //NSLog(@"Unknown event");
        }
	}
    
}



-(void) sendData:(void *) data packetID:(int)packetID ofLength:(int)length
{
    static unsigned char networkPacket[1024];
    const unsigned int packetHeaderSize = sizeof(int); // we have two "ints" for our header
	
    if(length < (1024 - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
        int *pIntData = (int *)&networkPacket[0];
        // header info
        pIntData[0] = packetID;
        // copy data in after the header
        memcpy( &networkPacket[packetHeaderSize], data, length);
        [self.outputStream write:networkPacket maxLength:length + 4];
    }
}

-(void)sendInfoPacket
{
    AccountDataSource *playerAccount = [AccountDataSource sharedInstance];
    static unsigned char networkPacket[1024];
    int money = playerAccount.money;
    int *moneyData = (int *)&networkPacket[0];
    moneyData[0] = money;
  
    int rang = playerAccount.accountLevel;
    int *rangData = (int *)&networkPacket[sizeof(int)];
    rangData[0] = rang;
    
    int atack = playerAccount.accountWeapon.dDamage;
    int *atackData = (int *)&networkPacket[sizeof(int) * 2];
    atackData[0] = atack;
    
    int defence = playerAccount.accountDefenseValue;
    int *defenceData = (int *)&networkPacket[sizeof(int) * 3];
    defenceData[0] = defence;

    const char *serverDisplayName = [playerAccount.accountName cStringUsingEncoding:NSUTF8StringEncoding];
    int displayNameLen = strlen(serverDisplayName);
    int *displayNameData = (int *)&networkPacket[sizeof(int) * 4];
    displayNameData[0] = displayNameLen;

    memcpy( &networkPacket[sizeof(int) * 5], (void *)serverDisplayName, sizeof(char) * displayNameLen);
  
    int nameLen = [playerAccount.accountID length];
    int *nameLenData = (int *)&networkPacket[sizeof(int) * 5+sizeof(char) * displayNameLen];
    nameLenData[0] = nameLen;
    
    const char *name = [playerAccount.accountID cStringUsingEncoding:NSUTF8StringEncoding];
    
    memcpy( &networkPacket[sizeof(int) * 6 +sizeof(char) * displayNameLen],
           (void *)name,
           sizeof(char) * [playerAccount.accountID length]);
    
    NSString *someURL = playerAccount.avatar;
    const char *fbImageURL = [someURL cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy(&networkPacket[sizeof(int) * 6 + sizeof(char) * displayNameLen + sizeof(char) * [playerAccount.accountID length]],
           (void *)fbImageURL,
           sizeof(char) * [someURL length]);
    
    NSString *versionKey = @"ver3.1";
    const char *versionKeyChar = [versionKey cStringUsingEncoding:NSUTF8StringEncoding];
    
    memcpy(&networkPacket[sizeof(int) * 6 + sizeof(char) * displayNameLen + sizeof(char) * [playerAccount.accountID length] + sizeof(char) * [someURL length]],
           (void *)versionKeyChar,
           sizeof(char) * [versionKey length]);
    
    
    [self sendData:(void *)(networkPacket) packetID:NETWORK_POST_INFO ofLength:sizeof(int) * 6 + sizeof(char) * displayNameLen +sizeof(char) * [playerAccount.accountID length]+sizeof(char) * [someURL length] + sizeof(char) * [versionKey length]];
}

- (void) getListOnline;
{
    blockResponceListOnLine = NO;
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
    [self sendData:@"" packetID:NETWORK_GET_LIST_ONLINE ofLength:sizeof(int)];
}

- (void)getData:(uint8_t[4096])message andLength:(int)length
{
    NSLog(@"get data with packet id %d length %d", message[0], length);
    if(message[0] == NETWORK_GET_LIST_ONLINE) {
        if (blockResponceListOnLine) {
            return;
        }
        blockResponceListOnLine = YES;
        
        char *tempBuffer = (char *)&message[1];
        NSData *data = [[NSData alloc] initWithBytes:tempBuffer length:length-1];
        
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.delegate listOnlineResponse:output];
    }
    else if (message[0] >= NETWORK_TIME) {
            NSData *data = [[NSData alloc] initWithBytes:message length:length];
            [self.gameCenterViewController receiveData:data];
        }
    else if (message[0] == NETWORK_PAIR_SET_TRUE) {
        [self.gameCenterViewController matchStarted];
        [self.gameCenterViewController matchStartedSinxron];
    }else if (message[0] == NETWORK_PAIR_SET_FALSE) {
        [self sendData:@"" packetID:NETWORK_GET_LIST_ONLINE ofLength:sizeof(@"")];
        for (UIViewController *viewController in self.gameCenterViewController.parentVC.navigationController.viewControllers)
        {
            if ([viewController isKindOfClass:[ListOfItemsViewController class]]) {
                [viewController.navigationController popToViewController:viewController animated:YES];
                return;
            }
        }
        [self.gameCenterViewController.parentVC.navigationController popToViewController:[StartViewController sharedInstance] animated:YES];
    }else if (message[0] == NETWORK_DISCONNECT_PAIR) [self.gameCenterViewController lostConnection];
}

-(void)connectionTimeout
{
    if (blockResponceListOnLine) {
        return;
    }
    DLog(@"connectionTimeoutListOnline");

    blockResponceListOnLine = YES;
    [self.delegate connectionTimeoutListOnline];
}


- (void)sendKeepAlive
{
    if (self.firstPing) {
        self.firstPing = NO;
        [self sendInfoPacket];
    }else
    {
        NSNumber *number = [NSNumber numberWithInt:0];
        [self sendData:(__bridge void *)(number) packetID:NETWORK_PING ofLength:sizeof(int)];
    }
}


- (void)disconnect
{
    self.connectionOpen = NO;
    [self.pingTimer invalidate];
    [self.outputStream close];
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


@end
