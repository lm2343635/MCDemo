//
//  ShareTableViewController.m
//  MCDemo
//
//  Created by limeng on 2/14/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ShareTableViewController.h"
#import "AppDelegate.h"

@interface ShareTableViewController ()

@property (nonatomic, strong) AppDelegate *delegate;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic) NSInteger selectedRow;

-(void)copySampleFilesToDocDirIfNeeded;
-(NSArray *)getAllDocDirFiles;
-(void)didStartReceivingResourceWithNotification:(NSNotification *)notification;
-(void)updateReceivingProgressWithNotification:(NSNotification *)notification;
-(void)didFinishReceivingResourceWithNotification:(NSNotification *)notification;

@end

@implementation ShareTableViewController

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    _delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self copySampleFilesToDocDirIfNeeded];
    _files=[[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartReceivingResourceWithNotification:)
                                                 name:@"MCDidStartReceivingResourceNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReceivingProgressWithNotification:)
                                                 name:@"MCReceivingProgressNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishReceivingResourceWithNotification:)
                                                 name:@"didFinishReceivingResourceNotification"
                                               object:nil];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return _files.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell;
    if([[_files objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"fileIndentifier"];
        if(cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"fileIndentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        cell.textLabel.text=[_files objectAtIndex:indexPath.row];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
    } else  {
        cell=[tableView dequeueReusableCellWithIdentifier:@"receiedFileIndentifier"];
        NSDictionary *dictionary=[_files objectAtIndex:indexPath.row];
        NSString *receivedFileName=[dictionary objectForKey:@"resourceName"];
        NSString *peerDisplayName=[[dictionary objectForKey:@"peerID"] displayName];
        NSProgress *progress=[dictionary objectForKey:@"progress"];
        [(UILabel *)[cell viewWithTag:1] setText:receivedFileName];
        [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"from %@", peerDisplayName]];
        [(UIProgressView *)[cell viewWithTag:3] setProgress:progress.fractionCompleted];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([[_files objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        return 60.0;
    } else {
        return 80.0;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *selectedFile=[_files objectAtIndex: indexPath.row];
    UIActionSheet *confirmSending=[[UIActionSheet alloc] initWithTitle:selectedFile
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
    for(MCPeerID *peer in _delegate.mcManager.session.connectedPeers) {
        [confirmSending addButtonWithTitle:peer.displayName];
    }
    [confirmSending setCancelButtonIndex:[confirmSending addButtonWithTitle:@"Cancel"]];
    [confirmSending showInView:self.view];
    _selectedFile=[_files objectAtIndex:indexPath.row];
    _selectedRow=indexPath.row;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(buttonIndex!=_delegate.mcManager.session.connectedPeers.count) {
        NSString *filePath=[_documentsDirectory stringByAppendingPathComponent:_selectedFile];
        NSString *modifiedName=[NSString stringWithFormat:@"%@_%@", _delegate.mcManager.peerID.displayName, _selectedFile];
        NSURL *resourceURL=[NSURL fileURLWithPath:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress=[_delegate.mcManager.session sendResourceAtURL:resourceURL
                                                                       withName:modifiedName
                                                                         toPeer:[_delegate.mcManager.session.connectedPeers objectAtIndex:buttonIndex]
                                                          withCompletionHandler:^(NSError * _Nullable error) {
                                                              if(error) {
                                                                  NSLog(@"Sharing file error: %@", error.localizedDescription);
                                                              } else {
                                                                  UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"MCDemo"
                                                                                                                message:@"File was successfully sent."
                                                                                                               delegate:self
                                                                                                      cancelButtonTitle:nil
                                                                                                      otherButtonTitles:@"Great!", nil];
                                                                  [alert performSelectorOnMainThread:@selector(show)
                                                                                          withObject:nil
                                                                                       waitUntilDone:NO];
                                                                  [_files replaceObjectAtIndex:_selectedRow
                                                                                    withObject:_selectedFile];
                                                                  [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                                                              withObject:nil
                                                                                           waitUntilDone:NO];
                                                              }
                                                          }];
            [progress addObserver:self
                       forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
        });
    }
}

#pragma mark - Functions
-(void)copySampleFilesToDocDirIfNeeded {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory=[[NSString alloc] initWithString:[paths objectAtIndex:0]];
    NSString *file1Path=[_documentsDirectory stringByAppendingPathComponent:@"sample_file1.txt"];
    NSString *file2Path=[_documentsDirectory stringByAppendingPathComponent:@"sample_file2.txt"];
    NSFileManager *manager=[NSFileManager defaultManager];
    NSError *error;
    if(![manager fileExistsAtPath:file1Path]||![manager fileExistsAtPath:file2Path]) {
        [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file1"
                                                                ofType:@"txt"]
                         toPath:file1Path
                          error:&error];
        if(error) {
            NSLog(@"Copy file1 error: %@", error.localizedDescription);
            return;
        }
        [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file2"
                                                                ofType:@"txt"]
                         toPath:file2Path
                          error:&error];
        if(error) {
            NSLog(@"Copy file2 error: %@", error.localizedDescription);
            return;
        }
    }
}

-(NSArray *)getAllDocDirFiles {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFileManager *manager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *allFiles=[manager contentsOfDirectoryAtPath:_documentsDirectory
                                                   error:&error];
    if(error) {
        NSLog(@"Loading files errer: %@", error.localizedDescription);
        return nil;
    }
    return allFiles;
}

-(void)didStartReceivingResourceWithNotification:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_files addObject:[notification userInfo]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
}

-(void)updateReceivingProgressWithNotification:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSProgress *progress=[[notification userInfo] objectForKey:@"progress"];
    NSDictionary *dictionary=[_files objectAtIndex:_files.count-1];
    NSDictionary *updateDictionary=@{
                                     @"resourceName": [dictionary objectForKey:@"resourceName"],
                                     @"peerID": [dictionary objectForKey:@"peerID"],
                                     @"progress": progress
                                     };
    [_files replaceObjectAtIndex:_files.count-1
                      withObject:updateDictionary];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
}

-(void)didFinishReceivingResourceWithNotification:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *dictionary=[notification userInfo];
    NSURL *localURL=[dictionary objectForKey:@"localURL"];
    NSString *resourceName=[dictionary objectForKey:@"resourceName"];
    NSString *destinationPath=[_documentsDirectory stringByAppendingPathComponent:resourceName];
    NSURL *destinationURL=[NSURL fileURLWithPath:destinationPath];
    NSFileManager *manager=[NSFileManager defaultManager];
    NSError *error;
    [manager copyItemAtURL:localURL
                     toURL:destinationURL
                     error:&error];
    if(error) {
        NSLog(@"Copying file error: %@", error.localizedDescription);
    }
    [_files removeAllObjects];
    _files=nil;
    _files=[[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
}

#pragma mark - Observer
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *sendingMessage=[NSString stringWithFormat:@"%@ - Sending %.f%%", _selectedFile, [(NSProgress *)object fractionCompleted]*100];
    [_files replaceObjectAtIndex:_selectedRow
                      withObject:sendingMessage];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
}
@end
