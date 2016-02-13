//
//  FirstViewController.m
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController ()

@property (nonatomic, strong) AppDelegate *delegate;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification: (NSNotification *)notification;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    _delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self sendMyMessage];
    return YES;
}

#pragma mark - Action
- (IBAction)sendMessage:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self sendMyMessage];
}

- (IBAction)cancelMessage:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_messageTextField resignFirstResponder];
}

#pragma mark - Functions
-(void)sendMyMessage {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([_messageTextField.text isEqualToString:@""]) {
        [_messageTextField resignFirstResponder];
        return;
    }
    NSData *dataToSend=[_messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers=_delegate.mcManager.session.connectedPeers;
    NSError *error;
    [_delegate.mcManager.session sendData:dataToSend
                                  toPeers:allPeers
                                 withMode:MCSessionSendDataReliable
                                    error:&error];
    if(error) {
        NSLog(@"Error in sending: %@", error.localizedDescription);
    }
    [_chatTextView setText:[_chatTextView.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _messageTextField.text]]];
    [_messageTextField setText:@""];
    [_messageTextField resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification {
    MCPeerID *peerID=[[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName=peerID.displayName;
    NSData *receivedData=[[notification userInfo] objectForKey:@"data"];
    NSString *receivedText=[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [_chatTextView performSelectorOnMainThread:@selector(setText:)
                                    withObject:[_chatTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]]
                                 waitUntilDone:NO];
}
@end
