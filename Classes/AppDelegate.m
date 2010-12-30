#import "AppDelegate.h"
#import "ClassesController.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// To set the status bar as black, use the following:
	//application.statusBarStyle = UIStatusBarStyleOpaqueBlack;
	
	// create window 
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
	// set up main view navigation controller
	ClassesController *navController = [[ClassesController alloc] initWithStyle:UITableViewStyleGrouped];
	
	// create a navigation controller using the new controller
	navigationController = [[UINavigationController alloc] initWithRootViewController:navController];
	[navController release];
	
	
	//[app release];

	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
  [navigationController release];
  [window release];
  [super dealloc];
}

@end
