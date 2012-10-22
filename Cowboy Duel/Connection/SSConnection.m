//
//  SSConnection.m
//  TCPClient
//
//  Created by Sergey Sobol on 11.10.12.
//  Copyright (c) 2012 Sergey Sobol. All rights reserved.
//

#import "SSConnection.h"
#import "AccountDataSource.h"


@interface SSConnection ()
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) NSTimer *pingTimer;
@property (nonatomic) BOOL firstPing;

@end


static SSConnection *connection;

@implementation SSConnection

@synthesize inputStream, outputStream;

+(id)sharedInstance
{
    if (!connection) {
        connection = [[SSConnection alloc] init];
        [connection networkCommunicationWithPort:@"8888" andIp:@"176.34.226.109"];
    }
    return connection;
}

- (void)networkCommunicationWithPort:(NSString *)port andIp:(NSString *)ip {
    if(self.outputStream && (self.outputStream.streamStatus != NSStreamStatusClosed)) return;
       
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
            break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSData *data = [[NSData alloc] initWithBytes:buffer length:len];
                        //[self.delegate getData:data andLength:len];
                        
                        
                        [self getData:buffer andLength:len];
                    }
                }
            }
			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:{}
			//NSLog(@"Unknown event");
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
        NSString *output = [[NSString alloc] initWithBytes:networkPacket length:length encoding:NSUTF8StringEncoding];
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
  
    int displayNameLen = [[UIDevice currentDevice].name length];
    int *displayNameData = (int *)&networkPacket[sizeof(int) * 2];
    displayNameData[0] = displayNameLen;
    
    const char *serverDisplayName = [[UIDevice currentDevice].name cStringUsingEncoding:NSUTF8StringEncoding];
    memcpy( &networkPacket[sizeof(int) * 3], (void *)serverDisplayName, sizeof(char) * [[UIDevice currentDevice].name length]);
    
    int nameLen = [[UIDevice currentDevice].uniqueIdentifier length];
    int *nameLenData = (int *)&networkPacket[sizeof(int) * 3+sizeof(char) * [[UIDevice currentDevice].name length]];
    nameLenData[0] = nameLen;
    
    const char *name = [[UIDevice currentDevice].uniqueIdentifier cStringUsingEncoding:NSUTF8StringEncoding];
    
    memcpy( &networkPacket[sizeof(int) * 4 +sizeof(char) * [[UIDevice currentDevice].uniqueIdentifier length]],
           (void *)name,
           sizeof(char) * [[UIDevice currentDevice].uniqueIdentifier length]);
    
    NSString *someURL = playerAccount.avatar;
    const char *fbImageURL = [someURL cStringUsingEncoding:NSUTF8StringEncoding ];
    memcpy(&networkPacket[sizeof(int) * 4 + sizeof(char) * [[UIDevice currentDevice].name length] + sizeof(char) * [[UIDevice currentDevice].uniqueIdentifier length]],
           (void *)fbImageURL,
           sizeof(char) * [someURL length]);
    
    [self sendData:(void *)(networkPacket) packetID:NETWORK_POST_INFO ofLength:sizeof(int) * 4 + sizeof(char) * [[UIDevice currentDevice].name length] +sizeof(char) * [[UIDevice currentDevice].uniqueIdentifier length]+sizeof(char) * [someURL length]];
}

- (void)getData:(uint8_t[1024])message andLength:(int)length
{
    NSLog(@"get data with packet id %d", message[0]);
    if(message[0] == NETWORK_GET_LIST_ONLINE) {
        char *tempBuffer = (char *)&message[1];
        NSData *data = [[NSData alloc] initWithBytes:tempBuffer length:length-1];
        
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.delegate listOnlineResponse:output];
    }
    else
    {
        if (message[0]>=NETWORK_TIME) {
            NSData *data = [[NSData alloc] initWithBytes:message length:length];
            [self.gameCenterViewController receiveData:data];
        }
        
            
    }
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
    [self.pingTimer invalidate];
    [self.outputStream close];
    [self.inputStream close];
}
@end
