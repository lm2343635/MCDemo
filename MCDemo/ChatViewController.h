//
//  FirstViewController.h
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;

- (IBAction)sendMessage:(id)sender;
- (IBAction)cancelMessage:(id)sender;

@end

