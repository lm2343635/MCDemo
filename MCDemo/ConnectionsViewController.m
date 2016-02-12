//
//  ConnectionsViewController.m
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

@interface ConnectionsViewController ()

@property (nonatomic, strong) AppDelegate *delegate;
@property (nonatomic, strong) NSMutableArray *connectedDevices;

-(void)peerDidChangeStateWithNotification: (NSNotification *)notification;

@end

@implementation ConnectionsViewController

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    _delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [_delegate.mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [_delegate.mcManager advertiseSelf:_visibleSwitch.isOn];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    _connectedDevices=[[NSMutableArray alloc] init];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return _connectedDevices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.textLabel.text = [_connectedDevices objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - MCBrowserViewControllerDelegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_nameTextField resignFirstResponder];
    _delegate.mcManager.peerID=nil;
    _delegate.mcManager.session=nil;
    _delegate.mcManager.browserViewController=nil;
    if(_visibleSwitch.isOn) {
        [_delegate.mcManager.advertiserAssistant stop];
    }
    _delegate.mcManager.advertiserAssistant=nil;
    [_delegate.mcManager setupPeerAndSessionWithDisplayName:_nameTextField.text];
    [_delegate.mcManager setupMCBrowser];
    [_delegate.mcManager advertiseSelf:_visibleSwitch.isOn];
    return YES;
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager setupMCBrowser];
    [_delegate.mcManager.browserViewController setDelegate:self];
    [self presentViewController:_delegate.mcManager.browserViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)toggleVisibility:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager advertiseSelf:_visibleSwitch.isOn];
}

- (IBAction)disconnect:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _nameTextField.enabled=YES;
    [_connectedDevices removeAllObjects];
    [_connectedDevicesTableView reloadData];
}

#pragma mark - Notification
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    MCPeerID *peerID=[[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName=peerID.displayName;
    MCSessionState state=[[[notification userInfo] objectForKey:@"state"] intValue];
    if (state!=MCSessionStateConnecting) {
        if(state==MCSessionStateConnected) {
            [_connectedDevices addObject:peerDisplayName];
        } else if (state==MCSessionStateNotConnected) {
            if(_connectedDevices.count>0) {
                [_connectedDevices removeObjectAtIndex:[_connectedDevices indexOfObject:peerDisplayName]];
            }
        }
        NSLog(@"%@", _connectedDevices);
        [_connectedDevicesTableView reloadData];
        BOOL peerExsit=(_delegate.mcManager.session.connectedPeers.count==0);
        [_disconnectButton setEnabled:!peerExsit];
        [_nameTextField setEnabled:peerExsit];
    }
}
@end
