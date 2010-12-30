#import <UIKit/UIKit.h>

@interface ClassesController : UITableViewController <UITextFieldDelegate>{
	UITextField *username;
	UITextField *password;
	NSMutableArray *data;
	
	UIAlertView *progressAlert;
	NSString *ip;
}

@property (nonatomic, retain) UITextField *username;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) UIAlertView *progressAlert;
@property (nonatomic, retain) NSString *ip;

@end
