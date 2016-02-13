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
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self=[super init];
    if(self) {
        _peerID=nil;
        _session=nil;
        _browserViewController=nil;
        _advertiserAssistant=nil;
    }
    return self;
}

#pragma mark - MCSessionDelegate
-(void)session:(MCSession *)session
          peer:(MCPeerID *)peerID
didChangeState:(MCSessionState)state {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *dictionary=@{
                               @"peerID": peerID,
                               @"state": [NSNumber numberWithInt:state]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dictionary];
}

-(void)session:(MCSession *)session
didReceiveData:(NSData *)data
      fromPeer:(MCPeerID *)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *dictionary=@{
                               @"data": data,
                               @"peerID": peerID
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dictionary];
}

-(void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
  withProgress:(NSProgress *)progress {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

-(void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
         atURL:(NSURL *)localURL
     withError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

-(void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

#pragma mark - Functions
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _peerID=[[MCPeerID alloc] initWithDisplayName:displayName];
    _session=[[MCSession alloc] initWithPeer:_peerID];
    _session.delegate=self;
}

-(void)setupMCBrowser {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _browserViewController=[[MCBrowserViewController alloc] initWithServiceType:@"chat-files"
                                                                        session:_session];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
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
