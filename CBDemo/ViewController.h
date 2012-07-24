//
//  ViewController.h
//  CBDemo
//
//  Created by Sergio on 25/01/12.
//  Copyright (c) 2012 Sergio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothMe.h"

typedef enum {
   BluetoothTypeHeartRate,
   BluetoothTypeAnimation,   
} BluetoothType;

@interface ViewController : UIViewController <BlueToothMeDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BlueToothMe* _bluetoothInstance;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BluetoothType bluetoothType;

@end
