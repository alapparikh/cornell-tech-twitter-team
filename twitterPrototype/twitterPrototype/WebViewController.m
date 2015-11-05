//
//  WebViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 11/4/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "WebViewController.h"
#import <UIKit/UIKit.h>

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *tweetView;

@end

@implementation WebViewController {
    NSURL *tweetURL;
}

-(void) viewDidLoad {
    
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:tweetURL];
    [self.tweetView loadRequest:request];
    
}

- (void) setURL: (NSURL *)url {
    tweetURL = url;
}

@end
