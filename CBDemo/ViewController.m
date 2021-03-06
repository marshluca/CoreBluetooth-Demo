//
//  ViewController.m
//  CBDemo
//
//  Created by Sergio on 25/01/12.
//  Copyright (c) 2012 Sergio. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "ExerciseViewController.h"

@implementation ViewController

@synthesize tableView, bluetoothType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Bluetooth Devices";
    
    if (self.bluetoothType == BluetoothTypeAnimation) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(exerciese)];        
    }    
    
    _bluetoothInstance = [BlueToothMe shared];
    [_bluetoothInstance setDelegate:self];
    
    /*
    NSArray *characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2A1E"], 
                                                         [CBUUID UUIDWithString:@"2A1C"],
                                                         [CBUUID UUIDWithString:@"2A21"], nil];
    
    [instance setCharacteristics:characteristics forServiceCBUUID:@"1809"];
    [instance setLetWriteDataCBUUID:[NSArray arrayWithObject:@"1809"]];
    
    characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A29"]];
                       
    [instance setCharacteristics:characteristics forServiceCBUUID:@"180A"];
    */
    
    [_bluetoothInstance hardwareResponse:^(CBPeripheral *peripheral, BLUETOOTH_STATUS status, NSError *error) {
        
        if (status == BLUETOOTH_STATUS_CONNECTED)
        {
            NSLog(@"connected!");
        }
        else if (status == BLUETOOTH_STATUS_FAIL_TO_CONNECT)
        {
            NSLog(@"fail to connect!");
        }
        else
        {
            NSLog(@"disconnected!");
        }
        
        NSLog(@"CBUUID: %@, ERROR: %@", (NSString *)peripheral.UUID, error.localizedDescription);
    }];
    
    [_bluetoothInstance startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_bluetoothInstance stopScan];
}

#pragma mark
#pragma mark - BlueToothMeDelegate

- (void)hardwareDidNotifyBehaviourOnCharacteristic:(CBCharacteristic *)characteristic
                                    withPeripheral:(CBPeripheral *)peripheral
                                             error:(NSError *)error
{
    
}

- (void)peripheralDidWriteChracteristic:(CBCharacteristic *)characteristic 
                         withPeripheral:(CBPeripheral *)peripheral 
                              withError:(NSError *)error
{
    NSLog(@"did write value : %@, %@", characteristic.service.UUID, characteristic.value);
}

- (void)peripheralDidReadChracteristic:(CBCharacteristic *)characteristic 
                        withPeripheral:(CBPeripheral *)peripheral 
                             withError:(NSError *)error
{
    NSLog(@"did read value for characteristic.UUID: %@, service.UUID: %@, characteristic.value:%@", characteristic.UUID, characteristic.service.UUID, characteristic.value);
    
    //if ([characteristic.service.UUID isEqual:[_bluetoothInstance.servicesCBUUID objectAtIndex:0]]) 
    {
        // NSLog(@"post notification for the service");
        [[NSNotificationCenter defaultCenter] postNotificationName:kReadValueNotification object:characteristic.value];    
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark
#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_bluetoothInstance.dicoveredPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    CBPeripheral *peripheral = [_bluetoothInstance.dicoveredPeripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    // cell.detailTextLabel.text = [peripheral isConnected] ? @"Connected" : @"Not connected";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = [_bluetoothInstance.dicoveredPeripherals objectAtIndex:indexPath.row];
    _bluetoothInstance.testPeripheral = peripheral;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectPeripheralNotification object:nil];
    
    if (self.bluetoothType == BluetoothTypeHeartRate) {
        DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        controller.title = peripheral.name;
        controller.title = @"HearRate";
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        ExerciseViewController *controller = [[ExerciseViewController alloc] initWithNibName:@"ExerciseViewController" bundle:nil];
        controller.title = peripheral.name;
        controller.title = @"Animation";        
        [self.navigationController pushViewController:controller animated:YES];

    }
}

- (void)exerciese
{
    ExerciseViewController *controller = [[ExerciseViewController alloc] initWithNibName:@"ExerciseViewController" bundle:nil];
    controller.title = @"Animation";
    [self.navigationController pushViewController:controller animated:YES];
}

@end
