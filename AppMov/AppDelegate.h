//
//  AppDelegate.h
//  AppMov
//
//  Created by Nuts on 9/11/19.
//  Copyright © 2019 Nuts. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "menuTabVC.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "movieDown.h"
#import "genreDown.h"

typedef void (^CompletionHandler)(void);
@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) NSString *homeDir;
@property (strong, nonatomic) menuTabVC * menTab;
@property (strong, nonatomic) UINavigationController *navCtrl;
@property (copy) CompletionHandler bgSessionCompHandler;

//@property(copy) void (^CompletionHandler)(void);
@property (strong, nonatomic) NSString *urlBase;

@property (strong, nonatomic) NSString *api_key;
@property (strong, nonatomic) NSString *urlImg;
@property (strong, nonatomic) movieDown *movDown;
@property (strong, nonatomic) genreDown *genDown;
//@property (strong, nonatomic) NSString *urlBase;
- (void)saveContext;


@end

