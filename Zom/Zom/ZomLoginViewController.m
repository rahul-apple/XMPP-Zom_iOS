//
//  ZomLoginViewController.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "ZomLoginViewController.h"
#import "ZomCountryPickerViewController.h"
#import "VROChatAPIHandler.h"
#import "UIViewController+ZomViewController.h"
#import "ZomUser.h"


@interface ZomLoginViewController ()<UITextFieldDelegate, ZomCountryCodeDelegate>
@property (nonatomic, strong) VROChatAPIHandler *apiHandler;

@end

@implementation ZomLoginViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
    self.apiHandler = [[VROChatAPIHandler alloc]init];
    
    // Do any additional setup after loading the view.
}

-(void)loadView {
    [super loadView];
    if (_isFromSignupPage) {
        _viewOTP.hidden = NO;
        _viewLogin.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
}

-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
    [self hideNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZomCountryCodeDelegate Delegate
- (void)countryCodeSelectionCompleted:(NSDictionary *)dict
{
    NSString *string = dict[@"country_code"];
    NSArray *words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nospacestring = [words componentsJoinedByString:@""];
    
    _textFieldCountryCode.text = nospacestring;
    _textFieldEmail.text = dict[@"country_name"];
    [_textFieldCountryCode upadteTextField:_textFieldCountryCode.frame];
    [_textFieldEmail upadteTextField:_textFieldEmail.frame];
    [_textFieldEmail setTextFieldPlaceholderText:@"Country"] ;

}

#pragma mark - UITextField Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 111) {
        [self.view endEditing:YES];
        if (self.navigationController.topViewController == self) {
            ZomCountryPickerViewController *countryPickerController = (ZomCountryPickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ZomCountryPickerViewController"];
            countryPickerController.delegate = self;
            [self.navigationController pushViewController:countryPickerController animated:YES];
        }
        return NO;
    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (![_scrollView focusNextTextField]) {
        [textField resignFirstResponder];
    };
    return true;
}


- (IBAction)buttonActionChangeType:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.tag = sender.tag == 0 ? 1 : 0;
    
    _textFieldEmail.text = @"";
    _textFieldCountryCode.text = @"";
    _viewMobileNumber.hidden = sender.tag == 0;
    _textFieldPassword.hidden = sender.tag == 1;
    
    
    if (sender.tag == 1) {
        _textFieldEmail.tag = 111;
        [_textFieldEmail setTextFieldPlaceholderText:@"Country"];
        [sender setTitle:@"Login By Email" forState:UIControlStateNormal];
    } else {
        _textFieldEmail.tag = 0;
        [_textFieldEmail setTextFieldPlaceholderText:@"Email"];
        [sender setTitle:@"Login By Mobile" forState:UIControlStateNormal];
    }
    
}

- (IBAction)buttonActionChangeNumber:(UIButton *)sender {
    [self.view endEditing:NO];
    if (_isFromSignupPage) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _viewOTP.hidden = YES;
        _viewLogin.hidden = NO;
    }
}

- (IBAction)buttonActionLogin:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.view endEditing:NO];
        if (self.textFieldEmail.text.length==0||self.textFieldPassword.text.length==0) {
            [self showWarning:@"Please fill all fields"];
            return;
        }
        self.view.userInteractionEnabled = NO;
        [self.apiHandler loginWithEmail:_textFieldEmail.text password:_textFieldPassword.text success:^(id responseObject) {
            if (![responseObject valueForKey:@"error"]) {
                [[ZomUser sharedInstance] setUserDetails:responseObject];
                OTRXMPPAccount *account = [OTRXMPPAccount new];
                account.username = [ZomUser sharedInstance].xmppUsername;
                account.password = [ZomUser sharedInstance].xmppPassword;
                account.rememberPassword = YES;
                account.autologin = YES;
                
//                [[OTRProtocolManager sharedInstance] loginAccount:account];
//                [[ZomAppDelegate appDelegate] showConversationViewController];
                OTRXMPPLoginHandler *loginHandler = [OTRXMPPLoginHandler new];
                XLFormDescriptor *form = [OTRXLFormCreator formForAccountType:OTRAccountTypeJabber createAccount:YES];
                [loginHandler performActionWithValidForm:form account:account progress:^(NSInteger progress, NSString *summaryString) {
                    NSLog(@"Tor Progress %d: %@", (int)progress, summaryString);
                    
                    
                } completion:^(OTRAccount *account, NSError *error) {
                    
                    if (error) {
                        // Unset/remove password from keychain if account
                        // is unsaved / doesn't already exist. This prevents the case
                        // where there is a login attempt, but it fails and
                        // the account is never saved. If the account is never
                        // saved, it's impossible to delete the orphaned password
                        __block BOOL accountExists = NO;
                        [[OTRDatabaseManager sharedInstance].readOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                            accountExists = [transaction objectForKey:account.uniqueId inCollection:[[OTRAccount class] collection]] != nil;
                        }];
                        if (!accountExists) {
                            [account removeKeychainPassword:nil];
                        }
                    } else {
                        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                            [account saveWithTransaction:transaction];
                        }];
                    }
                }];

            } else {
                [self showError:@"Login Unsuccessful" withMessage:[responseObject valueForKey:@"error_message"]];
            }
            self.view.userInteractionEnabled = YES;
        } failure:^(NSError *error) {
            if (error) {
                [self showError:@"Login Unsuccessful" withMessage:[error localizedDescription]];
            } else {
                [self showError:@"Login Unsuccessful" withMessage:@"Network error"];
            }
            self.view.userInteractionEnabled = YES;
        }];
    } else {
        
    }
}


- (IBAction)buttonActionVerify:(UIButton *)sender {
    
}


- (IBAction)buttonActionResendOTP:(UIButton *)sender {
    
}

@end
