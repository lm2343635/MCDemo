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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
}

- (IBAction)disconnect:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
@end
