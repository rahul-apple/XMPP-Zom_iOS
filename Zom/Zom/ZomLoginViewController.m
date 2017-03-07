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
    _constraintViewMobileHeight.constant = 0;
    _constraintViewMobileBottom.constant = 0;
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
    
    [self.view layoutIfNeeded];
    
    _constraintViewMobileHeight.constant = sender.tag == 1 ? 50.0 : 0;
    _constraintViewMobileBottom.constant = sender.tag == 1 ? 12.0 : 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        [_textFieldCountryCode upadteTextField:_textFieldCountryCode.frame];
        [_textFieldMobileNumber upadteTextField:_textFieldMobileNumber.frame];
        
    }];
    
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

-(void)loginSuccess:(id)responseObject {
    if (![responseObject valueForKey:@"error"]) {
        
        [[ZomUser sharedInstance] setUserDetails:responseObject];
        
        
        OTRXMPPAccount *account = [[OTRXMPPAccount alloc] init];
        account.username = [NSString stringWithFormat:@"%@@ec2-54-169-209-47.ap-southeast-1.compute.amazonaws.com", [ZomUser sharedInstance].xmppUsername];
        account.password = [ZomUser sharedInstance].xmppPassword;
        account.rememberPassword = YES;
        account.autologin = YES;
        
        
        //                [[OTRProtocolManager sharedInstance] loginAccount:account];
        //                [[ZomAppDelegate appDelegate] showConversationViewController];
        OTRXMPPLoginHandler *loginHandler = [OTRXMPPLoginHandler new];
        
        XLFormDescriptor *form = [OTRXLFormCreator formForAccount:account];
        [loginHandler performActionWithValidForm:nil account:account progress:^(NSInteger progress, NSString *summaryString) {
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
            [self stopActivity];
        }];
        
    } else {
        [self showError:@"Login Unsuccessful" withMessage:[responseObject valueForKey:@"error_message"]];
        [self stopActivity];
    }
}

- (IBAction)buttonActionLogin:(UIButton *)sender {
    [self.view endEditing:NO];
    if (_buttonLoginByMobile.tag == 0) {
        if (self.textFieldEmail.text.length==0||self.textFieldPassword.text.length==0) {
            [self showWarning:@"Please fill all fields"];
            return;
        }
        if (![self isValidEmail:_textFieldEmail.text]) {
            [self showWarning:@"Please enter valid email"];
            return;
        }

        [self startActivity:YES];
        [self.apiHandler loginWithEmail:_textFieldEmail.text password:_textFieldPassword.text success:^(id responseObject) {
            [self loginSuccess:responseObject];
        } failure:^(NSError *error) {
            if (error) {
                [self showError:@"Login Unsuccessful" withMessage:[error localizedDescription]];
            } else {
                [self showError:@"Login Unsuccessful" withMessage:@"Network error"];
            }
            [self stopActivity];

        }];
    } else {
        if (self.textFieldEmail.text.length==0||self.textFieldPassword.text.length==0||self.textFieldMobileNumber.text.length==0) {
            [self showWarning:@"Please fill all fields"];
            return;
        }
        if (![self isValidPhone:[NSString stringWithFormat:@"%@%@", _textFieldCountryCode.text, _textFieldMobileNumber.text]]) {
            [self showWarning:@"Please enter valid mobile number"];
            return;
        }
        [self startActivity:YES];
        [self.apiHandler loginWithMobile:_textFieldMobileNumber.text password:_textFieldMobileNumber.text success:^(id responseObject) {
            [self loginSuccess:responseObject];
        } failure:^(NSError *error) {
            if (error) {
                [self showError:@"Login Unsuccessful" withMessage:[error localizedDescription]];
            } else {
                [self showError:@"Login Unsuccessful" withMessage:@"Network error"];
            }
            [self stopActivity];
        }];
    }
}

- (BOOL)isValidEmail:(NSString*)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)isValidPhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}


- (IBAction)buttonActionVerify:(UIButton *)sender {
    
}


- (IBAction)buttonActionResendOTP:(UIButton *)sender {
    
}

@end
