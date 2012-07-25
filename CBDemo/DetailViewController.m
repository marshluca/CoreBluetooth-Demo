//
//  DetailViewController.m
//  CBDemo
//
//  Created by Lin Zhang on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize hexLabel, decimalLabel, indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.indicator.hidden = NO;    
    self.hexLabel.hidden = YES;
    self.decimalLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabel:) name:kReadValueNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.hexLabel = nil;
    self.indicator = nil;    
    self.decimalLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReadValueNotification object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectPeripheralNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark
#pragma mark - Notification

- (void)updateLabel:(NSNotification *)notification
{
    if (self.hexLabel.hidden) {
        self.hexLabel.hidden = NO;
        self.decimalLabel.hidden = NO;        
        self.indicator.hidden = YES;
    }
    
    hexLabel.text = [NSString stringWithFormat:@"%@", [notification object]];    
    
    NSString *str = hexLabel.text;    
    if ([str hasPrefix:@"<06"] && [str hasSuffix:@">"]) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 3)
                                           withString:@""];
        str = [str stringByReplacingCharactersInRange:NSMakeRange(str.length-1, 1)
                                           withString:@""];                
        
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:str];        
        [scanner setScanLocation:0];
        [scanner scanHexInt:&result];
        
        str = [NSString stringWithFormat:@"%d", result];
    } else if ([str hasPrefix:@"<"] && [str hasSuffix:@">"]) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                           withString:@""];
        str = [str stringByReplacingCharactersInRange:NSMakeRange(str.length-1, 1)
                                           withString:@""];                
        
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:str];        
        [scanner setScanLocation:0];
        [scanner scanHexInt:&result];
        
        str = [NSString stringWithFormat:@"%d", result];
    } 

    decimalLabel.text = str;    
}

@end
