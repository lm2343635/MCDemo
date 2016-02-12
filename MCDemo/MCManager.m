//
//  MCManager.m
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager

-(instancetype)init {
    self=[super init];
    if(self) {
        _peerID=nil;
        _session=nil;
        _browserViewController=nil;
        _advertiserAssistant=nil;
    }
    return self;
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSDictionary *dictionary=@{
                               @"peerID": peerID,
                               @"state": [NSNumber numberWithInt:state]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dictionary];
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName {
    _peerID=[[MCPeerID alloc] initWithDisplayName:displayName];
    _session=[[MCSession alloc] initWithPeer:_peerID];
    _session.delegate=self;
}

-(void)setupMCBrowser {
    _browserViewController=[[MCBrowserViewController alloc] initWithServiceType:@"chat-files"
                                                                        session:_session];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise {
    if (shouldAdvertise) {
        _advertiserAssistant=[[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-files"
                                                                  discoveryInfo:nil
                                                                        session:_session];
        [_advertiserAssistant start];
    } else {
        [_advertiserAssistant stop];
        _advertiserAssistant=nil;
    }
}

@end
