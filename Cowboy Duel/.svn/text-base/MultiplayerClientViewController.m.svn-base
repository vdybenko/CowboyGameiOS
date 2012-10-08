//
//  MultiplayerClientViewController.m
//  Cowboy Duel 1
//
//  Created by Sergey Sobol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiplayerClientViewController.h"
#import "GameCenterViewController.h"
#import "StartViewController.h"

/********
 INCLUDES
 ********/

#include "sb_serverbrowsing.h"
#include "qr2.h"
#include "natneg.h"
#include "gsAvailable.h"

/********
 DEFINES
 ********/
#define GAME_NAME		_T("Cowiph")
#define SECRET_KEY		_T("xJTNZG")
#define INBUF_LEN 256


// ensure cross-platform compatibility for printf
#ifdef UNDER_CE
void RetailOutputA(CHAR *tszErr, ...);
#define printf RetailOutputA
#elif defined(_NITRO)
#include "../../common/nitro/screen.h"
#define printf Printf
#define vprintf VPrintf
#endif

/********
 GLOBAL VARS
 ********/
static gsi_bool UpdateFinished = gsi_false; // used to track status of server browser updates
//char *hostname;

// vars used by ACE connection to accept/send responses over the wire once connected with QR2 host
struct sockaddr_in otheraddr;
SOCKET clientSock = INVALID_SOCKET;
int clientConnected = 0;
int sendSinxron;
int got_data = 0;
ServerBrowser sb;  // server browser object initialized with ServerBrowserNew
char receiveBufferClient[256];

/********
 DEBUG OUTPUT
 ********/
#ifdef GSI_COMMON_DEBUG
#if !defined(_MACOSX) && !defined(_IPHONE)
static void DebugCallback(GSIDebugCategory theCat, GSIDebugType theType,
						  GSIDebugLevel theLevel, const char * theTokenStr,
						  va_list theParamList)
{
	GSI_UNUSED(theLevel);
	printf("[%s][%s] ", 
           gGSIDebugCatStrings[theCat], 
           gGSIDebugTypeStrings[theType]);
    
	vprintf(theTokenStr, theParamList);
}
#endif
#ifdef GSI_UNICODE
static void AppDebug(const unsigned short* format, ...)
{
	// Construct text, then pass in as ASCII
	unsigned short buf[1024];
    char tmp[2056];
	va_list aList;
	va_start(aList, format);
	_vswprintf(buf, 1024, format, aList);
    
    UCS2ToAsciiString(buf, tmp);
	gsDebugFormat(GSIDebugCat_App, GSIDebugType_Misc, GSIDebugLevel_Notice,
                  "%s", tmp);
}
#else
static void AppDebug(const char* format, ...)
{
	va_list aList;
	va_start(aList, format);
	gsDebugVaList(GSIDebugCat_App, GSIDebugType_Misc, GSIDebugLevel_Notice,
                  format, aList);
}
#endif
#else
#define AppDebug _tprintf
#endif

// simple reader function that tries to read data off the socket
int tryreadClient(SOCKET s)
{
    
    int len;
    struct sockaddr_in saddr;
    socklen_t saddrlen = sizeof(saddr);
    while (CanReceiveOnSocket(s))
    {
        // printf("recvfrom %ld", recvfrom(s, receiveBufferClient, sizeof(receiveBufferClient) - 1, 0, (struct sockaddr *)&saddr, &saddrlen));
        len = recvfrom(s, receiveBufferClient, sizeof(receiveBufferClient) - 1, 0, (struct sockaddr *)&saddr, &saddrlen);
        
        if (len < 0)
        {
            len = GOAGetLastError(s);
            printf("|Got recv error: %d\n", len);
            return -1;
        }
        receiveBufferClient[len] = 0;
        if (memcmp(receiveBufferClient, NNMagicData, NATNEG_MAGIC_LEN) == 0)
        {
            NNProcessData(receiveBufferClient, len, &saddr);
		} 
		else 
		{
//            printf("|Got data (%s:%d): %s\n", inet_ntoa(saddr.sin_addr),ntohs(saddr.sin_port), receiveBufferClient);
			got_data = 1;
            gameInfo *gs = (gameInfo *)&receiveBufferClient[4];
//            printf("|Got data: %d %d %d\n", gs->oponentShotTime, gs->oponentMoney,gs->randomTime);
            return 1;
            
		}
        
    }
    return 0;
}




// callback called as server browser updates process
static void SBCallback(ServerBrowser sb, SBCallbackReason reason, SBServer server, void *instance)
{
	int i; // for-loop ctr
	gsi_char * defaultString = _T("");  // default string for SBServerGet functions - returns if specified string key is not found
	int defaultInt = 0;  // default int value for SBServerGet functions - returns if specified int key is not found
	gsi_char anAddress[20] = { '\0' };  // to store server IP
    
	// retrieve the server ip
#ifdef GSI_UNICODE
	if (server)
		AsciiToUCS2String(SBServerGetPublicAddress(server),anAddress);
#else
	if (server)
		strcpy(anAddress, SBServerGetPublicAddress(server));
#endif
    
	switch (reason)
	{
        case sbc_serveradded:  // new SBServer added to the server browser list
            // output the server's IP and port (the rest of the server's basic keys may not yet be available)
            AppDebug(_T("Server Added: %s:%d\n"), anAddress, SBServerGetPublicQueryPort(server));
            break;
        case sbc_serverchallengereceived: // received ip verification challenge from server
            // informational, no action required
            break;
        case sbc_serverupdated:  // either basic or full information is now available for this server
            // retrieve and print the basic server fields (specified as a parameter in ServerBrowserUpdate)
            AppDebug(_T("ServerUpdated: %s:%d\n"), anAddress, SBServerGetPublicQueryPort(server));
            AppDebug(_T("  Host: %s\n"), SBServerGetStringValue(server, _T("hostname"), defaultString));
            AppDebug(_T("  Gametype: %s\n"), SBServerGetStringValue(server, _T("gametype"), defaultString));
            AppDebug(_T("  Map: %s\n"), SBServerGetStringValue(server, _T("mapname"), defaultString));
            AppDebug(_T("  Players/MaxPlayers: %d/%d\n"), SBServerGetIntValue(server, _T("numplayers"), defaultInt), SBServerGetIntValue(server, _T("maxplayers"), defaultInt));
            AppDebug(_T("  Ping: %dms\n"), SBServerGetPing(server));
            
            // if the server has full keys (ServerBrowserAuxUpdate), print them
            if (SBServerHasFullKeys(server))
            {
                // print some non-basic server info
                AppDebug(_T("  Frag limit: %d\n"), SBServerGetIntValue(server, _T("fraglimit"), defaultInt));
                AppDebug(_T("  Time limit: %d minutes\n"), SBServerGetIntValue(server, _T("timelimit"), defaultInt));
                AppDebug(_T("  Gravity: %d\n"), SBServerGetIntValue(server, _T("gravity"), defaultInt));
                
                // print player info
                AppDebug(_T("  Players:\n"));
                for(i = 0; i < SBServerGetIntValue(server, _T("numplayers"), 0); i++) // loop through all players on the server 
                {
                    // print player key info for the player at index i
                    AppDebug(_T("    %s\n"), SBServerGetPlayerStringValue(server, i, _T("player"), defaultString));
                    AppDebug(_T("      Score: %d\n"), SBServerGetPlayerIntValue(server, i, _T("score"), defaultInt));
                    AppDebug(_T("      Deaths: %d\n"), SBServerGetPlayerIntValue(server, i, _T("deaths"), defaultInt));
                    AppDebug(_T("      Team (0=Red/1=Blue): %d\n"), SBServerGetPlayerIntValue(server, i, _T("team"), defaultInt));
                    AppDebug(_T("      Ping: %d\n"), SBServerGetPlayerIntValue(server, i, _T("ping"), defaultInt));
                    
                }
                // print team info (team name and team score)
                AppDebug(_T("  Teams (Score):\n"));
                for(i = 0; i < SBServerGetIntValue(server, _T("numteams"), 0); i++) 
                {
                    AppDebug(_T("    %s (%d)\n"), SBServerGetTeamStringValue(server, i, _T("team"), defaultString),
                             SBServerGetTeamIntValue(server, i, _T("score"), defaultInt));
                }
            }
            break;
        case sbc_serverupdatefailed:
            AppDebug(_T("Update Failed: %s:%d\n"), anAddress, SBServerGetPublicQueryPort(server));
            break;
        case sbc_updatecomplete: // update is complete; server query engine is now idle (not called upon AuxUpdate completion)
            AppDebug(_T("Server Browser Update Complete\r\n")); 
            UpdateFinished = gsi_true; // this will let us know to stop calling ServerBrowserThink
            break;
        case sbc_queryerror: // the update returned an error 
            AppDebug(_T("Query Error: %s\n"), ServerBrowserListQueryError(sb));
            UpdateFinished = gsi_true; // set to true here since we won't get an updatecomplete call
            break;
        default:
            break;
	}
    
	GSI_UNUSED(instance);
}

// callback triggered by ACE
static void SBConnectCallback(ServerBrowser serverBrowser, SBConnectToServerState state, SOCKET gamesocket, struct sockaddr_in *remoteaddr, void *instance)
{
    struct sockaddr_in saddr;
    socklen_t namelen = sizeof(saddr);
    if (gamesocket != INVALID_SOCKET)
    {
        getsockname(gamesocket, (struct sockaddr *)&saddr, &namelen);
        printf("|Local game socket: %d\n", ntohs(saddr.sin_port));
    }    
    
    // success - we have connected to our QR2 host server
    if (state == sbcs_succeeded)
    {
        printf("Connected to server, remoteaddr: %s, remoteport: %d\n", 
               (remoteaddr == NULL) ? "" : inet_ntoa(remoteaddr->sin_addr), 
               (remoteaddr == NULL) ? 0 : ntohs(remoteaddr->sin_port));
        
        // copy off the socket and addr to send replies to the game host
        clientConnected = 1;
        memcpy(&otheraddr, remoteaddr, sizeof(otheraddr));
        clientSock = gamesocket;
    }
    else if (state == sbcs_failed)
        AppDebug(_T("Failed to connect to server"));     
    
    GSI_UNUSED(serverBrowser);
    GSI_UNUSED(instance);
}

@interface MultiplayerClientViewController (PrivateMethods)

-(void) sendCycle:(void *) data packetID:(int)packetID ofLength:(int)length;

@end

@implementation MultiplayerClientViewController
@synthesize gameCenterViewController, isRunClient, isFounsServerName;
gameInfo gameStat;
- (id)initWithServerName:(char *)serverName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        // [self shutDownClient];
        
        //        NSString *st=[NSString stringWithFormat:@"MultiplayerServer server name %s", serverName];
        //        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Allert" message:st delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //        [av show];
        
        isFounsServerName = nil;
        hostname = "";
        printf("MultiplayerServer server name %s\n", serverName);
        if (serverName) hostname = serverName;
        isRunClient = YES;
        serverRecponse = NO;
        sendSinxron = 1;
        [self performSelectorInBackground:@selector(createBrouser) withObject:self]; 
        
    }
    
    return self;
}


-(void) createBrouser
{
	
    
	/* ServerBrowserNew parameters */
	int version = 0;           // ServerBrowserNew parameter; set to 0 unless otherwise directed by GameSpy
	int maxConcUpdates = 20;	// max number of queries the ServerBrowsing SDK will send out at one time
	SBBool lanBrowse = SBFalse;   // set true for LAN only browsing
	void * userData = NULL;       // optional data that will be passed to the SBCallback function after updates
    
	/* ServerBrowserUpdate parameters */
	SBBool async = SBTrue;     // we will run the updates asynchronously
	SBBool discOnComplete = SBTrue; // disconnect from the master server after completing update 
    // (future updates will automatically re-connect)
	// these will be the only keys retrieved on server browser updates
	unsigned char basicFields[] = {HOSTNAME_KEY, GAMETYPE_KEY,  MAPNAME_KEY, NUMPLAYERS_KEY, MAXPLAYERS_KEY};
	int numFields = sizeof(basicFields) / sizeof(basicFields[0]); 
	gsi_char serverFilter[100] = {'\0'};  // filter string for server browser updates
    
	/* ServerBrowserSort parameters */
	SBBool ascending = SBTrue;        // sort in ascending order
	gsi_char * sortKey = _T("ping"); // sort servers based on ping time
	SBCompareMode compareMode = sbcm_int;  // we are sorting integers (as opposed to floats or strings)
    
	/* ServerBrowserAuxUpdateServer parameter */
	SBBool fullUpdate = SBTrue;
    
	GSIACResult result;	// used for backend availability check
	int i; // for-loop counter
	SBServer server; // used to hold each server when iterating through the server list
	int totalServers; // keep track of the total number of servers in our server list
	gsi_char * defaultString = _T(""); // default string for SBServerGet functions - returns if specified string key is not found
    gsi_time startTime = 0; 
    SBError nError = sbe_noerror;
    unsigned long lastsendtime = 0; // timer used with ACE to send data to connected clients every 2 seconds
    
  	// for debug output on these platforms
#if defined (_PS3) || defined (_PS2) || defined (_PSP) || defined (_NITRO)
#ifdef GSI_COMMON_DEBUG
    // Define GSI_COMMON_DEBUG if you want to view the SDK debug output
    // Set the SDK debug log file, or set your own handler using gsSetDebugCallback
    //gsSetDebugFile(stdout); // output to console
    gsSetDebugCallback(DebugCallback);
    
    // Set debug levels
    gsSetDebugLevel(GSIDebugCat_All, GSIDebugType_All, GSIDebugLevel_Verbose);
#endif
#endif
    
	// check that the game's backend is available
	GSIStartAvailableCheck(GAME_NAME);
	while((result = GSIAvailableCheckThink()) == GSIACWaiting)
		msleep(5);
	if(result != GSIACAvailable)
	{
		AppDebug(_T("The backend is not available\n"));
		return;
	}
	
	AppDebug(_T("Creating server browser for %s\n\n"), GAME_NAME);
	// create a new server browser object
	sb = ServerBrowserNew (GAME_NAME, GAME_NAME, SECRET_KEY, version, maxConcUpdates, QVERSION_QR2, lanBrowse, SBCallback, userData);
    
    /** Populate the server browser's server list by doing an Update **/
	AppDebug(_T("Starting server browser update\n"));
	// begin the update (async)
	nError = ServerBrowserUpdate(sb, async, discOnComplete, basicFields, numFields, serverFilter);
	if(nError)
	{
		printf("ServerBrowserUpdate Error 0x%x\n", nError);
		return;
	}
	
	// think while the update is in progress
	while (!UpdateFinished)
	{
		nError = ServerBrowserThink(sb);
		if(nError)
		{
			printf("ServerBrowserThink Error 0x%x\n", nError);
			return;
		}
		msleep(10);  // think should be called every 10-100ms; quicker calls produce more accurate ping measurements
	}
    
    /** End Update **/
    
    /** Sort the server list by ping time in ascending order **/
	AppDebug(_T("\nSorting server list by ping\n"));
	// sorting is typically done based on user input, such as clicking on the column header of the field to sort
	ServerBrowserSort(sb, ascending, sortKey, compareMode); 
    
	totalServers = ServerBrowserCount(sb); // total servers in our server list
	if (totalServers == 0)
		printf("There are no %s servers running currently\n", GAME_NAME);
	else 
	{
		printf("Sorted list:\n");
		// display the server list in the new sorted order
		for(i = 0; i < totalServers; i++)
		{
			server = ServerBrowserGetServer(sb, i);  // get the SBServer object at index 'i' in the server list
			if(!server)
			{
				printf("ServerBrowserGetServer Error!\n");
				return;
			}
            
			// print the server host along with its ping
			AppDebug(_T("  %s  ping: %dms\n"), SBServerGetStringValue(server, _T("hostname"), defaultString), SBServerGetPing(server));
		}
	}
    /** End server list sorting **/
    
    /** Refresh the server list, this time using a server filter **/
	AppDebug(_T("\nRefreshing server list and applying a filter: "));
	ServerBrowserClear(sb); // need to clear first so we don't end up with duplicates
	
	AppDebug(_T("US servers with more than 5 players, or servers with a hostname containing 'GameSpy'\n\n"));
    // filter in US servers that have more than 5 players, or any server containing 'GameSpy' in the hostname
	_tcscpy(serverFilter,_T("numplayers = 2"));
	// note that filtering by "ping" is not possible, since ping is determined by the client - not the master server
    
	// begin the update (async)
	nError = ServerBrowserUpdate(sb, async, discOnComplete, basicFields, numFields, serverFilter);
	if(nError)
	{
		printf("ServerBrowserUpdate w/ Filters Error 0x%x\n", nError);
		return;
	}
    
	UpdateFinished = gsi_false; // this was set to true from the last update, so we set it back until the new update completes
    
	// think once again while the update is in progress
	while (!UpdateFinished)
	{
		nError = ServerBrowserThink(sb);
		if(nError)
		{
			printf("ServerBrowserThink Error 0x%x\n", nError);
			return;
		}
		msleep(10);  // think should be called every 10-100ms; quicker calls produce more accurate ping measurements
	}
    
	/** End refresh with filter **/
    
    /** If the qr2 sample server is running, we will do an AuxUpdate to retrieve its full keys **/
	AppDebug(_T("\nLooking for GameSpy QR2 Sample server\n"));
	totalServers = ServerBrowserCount(sb); // total servers in our server list
	if (totalServers == 0){
		AppDebug(_T("There are no %s servers running currently\n"), GAME_NAME);
        // [self performSelectorOnMainThread:@selector(messageShow) withObject:nil waitUntilDone:YES];
    }
	else 
	{
        
		int serverFound = 0; // set to 1 if GameSpy QR2 Sample server is in the list
        printf("total servers %d\n", totalServers);
		// iterate through the server list looking for GameSpy QR2 Sample
		for(i = 0; i < totalServers; i++)
		{
			server = ServerBrowserGetServer(sb, i);  // get the SBServer object at index 'i' in the server list
			if(!server)
			{
				printf("ServerBrowserGetServer Error!\n");
				return;
			}
			
			// check if the hostname server key is "GameSpy QR2 Sample"
            
            bool serverForName;
            if (strcmp(hostname, "")){
                serverForName = _tcscmp(SBServerGetStringValue(server, _T("hostname"), defaultString), _T(hostname));
            }else
                serverForName = false;
            //            printf("hostname %s %s\n", hostname,SBServerGetStringValue(server, _T("hostname"), defaultString));
            if (!serverForName) 
			{  
                isFounsServerName = [NSString stringWithCString:SBServerGetStringValue(server, _T("hostname"), defaultString) encoding:NSUTF8StringEncoding];
                //printf("hostname %s\n", hostname);
				AppDebug(_T("Found it!\n\nRunning AuxUpdate to get more specific server info:\n\n"));
				// update the qr2 sample server object to contain its full keys 
				nError = ServerBrowserAuxUpdateServer(sb, server, async, fullUpdate);
				if(nError)
				{
					printf("ServerBrowserUpdate Error 0x%x\n", nError);
					return;
				}
				// Note: Only call this on a server currently in the server list; otherwise call ServerBrowserAuxUpdateIP
                
				// think once again while the update is in progress; done once the server object has full keys
				while (!SBServerHasFullKeys(server)) 
				{
					nError = ServerBrowserThink(sb);
					if(nError)
					{
						printf("ServerBrowserThink Error on AuxUpdateServer 0x%x\n", nError);
						return;
					}
					msleep(10);  // think should be called every 10-100ms; quicker calls produce more accurate ping measurements
				}
                
				serverFound = 1;
                
                // try to connect to server using ServerBrowserConnectToServerWithSocket (ACE)
                clientSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
                nError = ServerBrowserConnectToServerWithSocket(sb, server, clientSock, SBConnectCallback);
                if (nError)
                {
                    [self performSelectorOnMainThread:@selector(messageShow) withObject:nil waitUntilDone:YES];
                    AppDebug(_T("Error found trying to connect to server with ACE\n"));
					return;
                }
                else
                {
                    // Enter a wait state while trying to connect - if connected, start sending messages!
                    startTime = current_time();
                    pingCount = 0;
                    lastReceivedPacket = -1;
                    while ( isRunClient )
                    {
                        nError = ServerBrowserThink(sb);
						if(nError)
						{
                            [self performSelectorOnMainThread:@selector(messageShow) withObject:nil waitUntilDone:YES];
							printf("ServerBrowserThink Error on ACE check 0x%x\n", nError);
							return;
						}
                        
                        
                        if ((clientConnected) && (current_time() - startTime > 2000))
                        {
                            
                            startTime = current_time();
                            gameInfo *gs2 = &gameStat;
                            
                            pingCount++;
//                            printf("client send ping N %d!\n", pingCount);
                            [self sendCycle:gs2 packetID:NETWORK_PING ofLength:(sizeof(gameInfo)+10)];
                            if (pingCount == 5) {
                                //[self shutDownClient];
                                [self performSelectorOnMainThread:@selector(messageShow) withObject:nil waitUntilDone:YES];
                                isRunClient = NO;
                            }
                        }
                        
                        // w00t we connected to our host - time to start trash talking every 2 seconds!
                        
                        if ((clientConnected) && (isRunClient) && sendSinxron)
                        {
                            
                            printf("clientConnected send first data!\n");
                            
                            [gameCenterViewController clientConnected];
                            lastsendtime = current_time();
                            sendSinxron = 0;
                            
						} 
                        
                        
                        //printf("Socket state %d!\n", readReturn);
                        
						if (clientSock != INVALID_SOCKET){
                            int readReturn = tryreadClient(clientSock);
                            if (readReturn) [self performSelectorOnMainThread:@selector(receivePacket) withObject:nil waitUntilDone:YES];
                            //else printf("Socket is 0!\n");
                        }
						else
                        {
							printf("Socket is INVALID!\n");
                            self.isRunClient = NO;
                            neadSend = NO;
                            
                        }
						msleep(10);
                    }
                }
                [self shutDownClient];
                
                
				break;  // already found the qr2 sample server, no need to loop through the rest 
			}
		}
		if (!serverFound)
		{
			AppDebug(_T("Gamespy QR2 Sample server is not running\n"));
			return;
		}
		if (!clientConnected)
		{
			printf("ACE: SBConnectCallback Failed!\n");
			return;
		}
		if (!got_data)
		{
			printf("ACE: Never got data from qr2 host!\n");
			return;
		}
	}
    
    
	
    
	// Finished
	return;
}

-(void)shutDownClient
{
    printf("Shutting down client\n");
    // cleanup and close our ACE socket
    if (clientSock != INVALID_SOCKET)
        closesocket(clientSock);
    
    clientSock = INVALID_SOCKET;
    SocketShutDown();
    
    /** End AuxUpdate **/
    ServerBrowserFree(sb);             // clean up
    
	
    
}

-(void)receivePacket
{
    int *pIntData = (int *)&receiveBufferClient[0];
    int packetID = pIntData[0];
    printf("receivePacketID %d\n", packetID);
    
    if ((packetID != NETWORK_PING_RESPONSE) && (packetID != NETWORK_RESPONSE) && (packetID != NETWORK_ACCEL_STATE) &&(lastReceivedPacket == packetID)) {
        printf("MultiplayerClientViewController Packet is repeated!\n");
        [self sendResponse];
        return;
    }
    
    if ((packetID != NETWORK_PING_RESPONSE) && (packetID != NETWORK_RESPONSE))
        lastReceivedPacket = packetID;
    
    if (packetID == NETWORK_RESPONSE)
        neadSend = NO;
    if (packetID == NETWORK_PING_RESPONSE) {
        pingCount = 0;
    }
    
    serverRecponse = YES;
    
    NSData *packet = [NSData dataWithBytes: &receiveBufferClient length: (sizeof(gameInfo)+10)];
    [gameCenterViewController receiveData:packet];
}

-(void) sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length{
    neadSend = YES;
    
    [self sendCycle:data packetID:packetID ofLength:length];
    
    dataGlobal = data;
    packetIDGlobal = packetID;
    lengthGlobal = length;
    [self performSelectorInBackground:@selector(startCycle) withObject:nil];     
}

-(void)startCycle
{
    int tryCount = 1;
    int lastsendtime = current_time();
    while (neadSend) {
        
        if (current_time() - lastsendtime > 500)
        {
            tryCount++;
            [self sendCycle:dataGlobal packetID:packetIDGlobal ofLength:lengthGlobal];
            lastsendtime = current_time();
            
            if (tryCount > 10) {
                
                
                [self performSelectorOnMainThread:@selector(messageShow) withObject:nil waitUntilDone:YES];
                self.isRunClient = NO;
                if (clientSock != INVALID_SOCKET)
                    closesocket(clientSock);
                
                clientSock = INVALID_SOCKET;
                SocketShutDown();                    
                return;
                
            }
        }
        if (clientSock != INVALID_SOCKET){
            if (tryreadClient(clientSock)) 
                // [self receivePacket]; 
                [self performSelectorOnMainThread:@selector(receivePacket) withObject:nil waitUntilDone:YES];
        }
        else
        {
            printf("Socket is INVALID!\n");
            self.isRunClient = NO;
            neadSend = NO;
            
        }
        
        msleep(10);
        
    }
    
}



-(void) sendCycle:(void *) data packetID:(int)packetID ofLength:(int)length
{
    static unsigned char networkPacket[kMaxTankPacketSize];
	const unsigned int packetHeaderSize = sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxTankPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = packetID;
		
		
        
        // copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
        int ret = sendto(clientSock, networkPacket, sizeof(networkPacket), 0, (struct sockaddr *)&otheraddr, sizeof(struct sockaddr_in));
        int error = GOAGetLastError(sock);
//        printf("|Sending (%d:%d), remoteaddr: %s, remoteport: %d\n", ret, error, inet_ntoa(otheraddr.sin_addr), ntohs(otheraddr.sin_port));
    }
    
}

-(void)sendResponse
{
    
    gameInfo *gs = &gameStat;
    static unsigned char networkPacket[kMaxTankPacketSize];
	const unsigned int packetHeaderSize = sizeof(int); // we have two "ints" for our header
	
    // our networkPacket buffer size minus the size of the header info
    int *pIntData = (int *)&networkPacket[0];
    // header info
    pIntData[0] = NETWORK_RESPONSE;
    
    
    
    // copy data in after the header
    memcpy( &networkPacket[packetHeaderSize], gs, sizeof(gameInfo)); 
    
    int ret = sendto(clientSock, networkPacket, sizeof(networkPacket), 0, (struct sockaddr *)&otheraddr, sizeof(struct sockaddr_in));
    int error = GOAGetLastError(sock);
//    printf("|Sending (%d:%d), remoteaddr: %s, remoteport: %d\n", ret, error, inet_ntoa(otheraddr.sin_addr), ntohs(otheraddr.sin_port));
}

-(void)messageShow
{
    [gameCenterViewController lostConnection];
    [self messageShowOnChat];
    //    [self performSelector:@selector(messageShowOnChat) withObject:nil afterDelay:3.0];
    
}

-(void)messageShowOnChat
{
    StartViewController *startViewController = (StartViewController *)gameCenterViewController.parentVC;
}





@end
