#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> {	
  UIWindow *window;
  UINavigationController *navigationController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

