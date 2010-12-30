
#import <objc/objc.h>
#import <objc/runtime.h>
#include <sys/socket.h>
#include <unistd.h>
#include <CFNetwork/CFNetwork.h>

#import "ClassesController.h"
#import "AppDelegate.h"
#import "IPAddress.h"
#import "RegexKitLite.h"
#import "HttpRequest.h"

typedef struct _DATA
{
	NSMutableString *pstr;
	bool bGrab;
} DATA;

@implementation ClassesController
@synthesize username, password, data, progressAlert, ip;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *CellIdentifier = @"cell";
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	NSUInteger row = [indexPath row];
	
	CGRect frame = CGRectMake(80.0, 8.0, 220.0, 30.0);
    	if (row == 0) {
		username = [[UITextField alloc] initWithFrame:frame];
		username.font = [UIFont boldSystemFontOfSize:18];
		username.textColor = [UIColor darkGrayColor];
		username.textAlignment = UITextAlignmentLeft;
		username.text = [data objectAtIndex:0];
		username.borderStyle = UITextBorderStyleRoundedRect;
		username.placeholder = @"请输入您的Email账户";
		username.backgroundColor = [UIColor whiteColor];
		username.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		username.keyboardType = UIKeyboardTypeASCIICapable;	// use the default type input method (entire keyboard)
		username.returnKeyType = UIReturnKeyDone;
		username.delegate=self;
		[cell addSubview:username];
		[username becomeFirstResponder];
		//cell = [[[ListCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.text = @"账  户：";
	} else if (row == 1) {
		password = [[UITextField alloc] initWithFrame:frame];
		password.font = [UIFont boldSystemFontOfSize:18];
		password.textColor = [UIColor darkGrayColor];
		password.textAlignment = UITextAlignmentLeft;
		password.text = [data objectAtIndex:1];
		password.borderStyle = UITextBorderStyleRoundedRect;
		password.placeholder = @"请输入您的Email密码";
		password.backgroundColor = [UIColor whiteColor];
		password.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		password.keyboardType = UIKeyboardTypeASCIICapable;	// use the default type input method (entire keyboard)
		password.returnKeyType = UIReturnKeyDone;
		password.secureTextEntry = YES;
		password.delegate=self;
		[cell addSubview:password];
		//cell = [[[ListCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.text = @"密  码：";
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (cell == nil) {
        	cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	return cell;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)loadView {
	[super loadView];
	self.title = @"百度Mobile准入";
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
							initWithTitle:@"准入" 
							style:UIBarButtonItemStylePlain 
							target:self 
							action:@selector(access)] autorelease];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
							initWithTitle:@"帮助" 
							style:UIBarButtonItemStylePlain 
							target:self 
							action:@selector(about)] autorelease];
	self.tableView.scrollEnabled = NO;
	
	//检查Documents下的user.plist是否存在
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *userPlist=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.plist"];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if(![fm fileExistsAtPath:userPlist]) {
		//文件不存在 从主程序目录复制过去一个
		NSString *srcUserPlist = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"user.plist"];
		
		[fm copyItemAtPath:srcUserPlist toPath:userPlist error:nil];
	}

	data=[[NSMutableArray alloc] initWithContentsOfFile:userPlist];
	
	//获取IP
	InitAddresses();
   	GetIPAddresses();
    	GetHWAddresses();
    	int i;
    	NSString *localIP = @"172.";  //baidu内网都是以172开头 用这个来判断获取的是WIFI的IP还是蜂窝网络的IP
	NSArray  *matchArray   = NULL;
	NSString *tmpIP;
	
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;
		unsigned long theAddr;
		
		theAddr = ip_addrs[i];
		
		if (theAddr == 0) break;
		if (theAddr == localHost) continue;
		
		//这里不知道为什么用 hasPrefix 就会出问题 所以只能用正则了
		tmpIP = [NSString stringWithFormat:@"%s", ip_names[i]];
		matchArray = [tmpIP componentsMatchedByRegex:localIP];
		if([matchArray count] > 0) {
			ip = tmpIP;
		}
		matchArray = NULL;
	}
	
	//判断一下读取到IP没有
	if(![ip hasPrefix:localIP]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误！" message:@"获取IP失败，请确认你是否已经连接到SSID为BaiduMobile的WIFI！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
	}
	
	
	
}

- (void)dealloc {
	[username release];
	[password release];
	[data release];
	[progressAlert release];
	[ip release];
	[super dealloc];
}

- (void)about {  
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"帮助" message:@"百度非官方Mobile准入，避免了多次输入帐号密码，请在加入SSID为BaiduMobile的WIFI后再运行本程序，并在每次锁屏后运行本程序一次。\n作者：dongliqiang@baidu.com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];	
	[alertView show];
	[alertView release];
}

- (void)access {

	NSString *usernameText=[username text];
	NSString *passwordText=[password text];
	
	if(usernameText.length < 1 || passwordText.length < 1) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"帐号密码都懒得写神马的最讨厌了！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];	
		[alertView show];
		[alertView release];
	} else {
		//检查IP
		if([ip hasPrefix:@"172."]) {
			progressAlert = [[UIAlertView alloc] initWithTitle: @"提示"
								message: @"正在准入，请稍后..."
								delegate: self
								cancelButtonTitle: nil
								otherButtonTitles: nil];
			UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
			[activityView startAnimating];
			[progressAlert addSubview:activityView];
			[progressAlert show];
			[progressAlert release];
			
			[data replaceObjectAtIndex:0 withObject: usernameText];
			[data replaceObjectAtIndex:1 withObject: passwordText];
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
			NSString *filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.plist"];  
			
			[data writeToFile:filename atomically:YES];
			
			[NSThread detachNewThreadSelector:@selector(posting) toTarget:self withObject:nil];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误！" message:@"获取IP失败，请确认你是否已经连接到SSID为BaiduMobile的WIFI！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
	}
}

- (void)posting {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	UIApplication* application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;

	NSString *url = @"https://1.1.1.1/login.html";

	NSString* error;
	NSMutableString * content = [[NSMutableString alloc] init];
	NSMutableString * headers = [[NSMutableString alloc] init];
	
	NSString *post = [NSString stringWithFormat:@"buttonClicked=4&err_flag=0&err_msg=&info_flag=0&info_msg=&redirect_url=&username=%@&password=%@",[data objectAtIndex:0], [data objectAtIndex:1]];
	
	bool ret = HttpRequest(url, ip, content, headers, post, error);
	
	application.networkActivityIndicatorVisible = NO;
	
	if(ret) {

		NSString *passFlag = @"<title>Logged In</title>";
		
		NSArray  *matchArray   = [content componentsMatchedByRegex:passFlag];
		
		if([matchArray count] > 0) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"准入通过" message:@"现在你可以关闭本程序了。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		} else {
		
			NSString *errFlag = @"<INPUT TYPE=\"hidden\" NAME=\"err_flag\" SIZE=\"16\" MAXLENGTH=\"15\" VALUE=\"(.*)\">";
			int errMatched = [[content stringByMatching:errFlag capture:1] intValue];
			if(errMatched > 0) {
				//账号密码错误
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"准入失败" message:@"账号或密码错误！请输入您邮箱的账号和密码！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			} else {
				//错误信息
				passFlag = @"<INPUT TYPE=\"hidden\" NAME=\"info_msg\" SIZE=\"32\" MAXLENGTH=\"31\" VALUE=\"(.*)\">";
				NSString *info = [content stringByMatching:passFlag capture:1];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"准入失败" message:info delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
		}
	} else {
	 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"准入失败" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	[self performSelectorOnMainThread:@selector(posted) withObject:nil waitUntilDone:NO];
	
	[pool release];
}
- (void)posted {

   [progressAlert dismissWithClickedButtonIndex:0 animated:YES];

   [self dismissModalViewControllerAnimated:YES];
}

@end
