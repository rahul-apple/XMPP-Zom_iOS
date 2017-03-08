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
#import "ZomOverrides.h"



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
        if (!self.form)
            self.form = [OTRXLFormCreator formForAccountType:OTRAccountTypeJabber createAccount:NO];

        if (!self.account) {
            self.account = [[OTRXMPPAccount alloc] init];

        }
        
        self.account.username = [NSString stringWithFormat:@"%@@%@", [ZomUser sharedInstance].xmppUsername, XMPPHostName];
        self.account.password = [ZomUser sharedInstance].xmppPassword;
        self.account.rememberPassword = YES;
        self.account.autologin = YES;
        
        XLFormRowDescriptor *usernameRow = [self.form formRowWithTag:kOTRXLFormUsernameTextFieldTag];
        XLFormRowDescriptor *passwordRow = [self.form formRowWithTag:kOTRXLFormPasswordTextFieldTag];
        usernameRow.value = [NSString stringWithFormat:@"%@@%@", [ZomUser sharedInstance].xmppUsername, XMPPHostName];;
        passwordRow.value = [ZomUser sharedInstance].xmppPassword;
        
        //                [[OTRProtocolManager sharedInstance] loginAccount:account];
        //                [[ZomAppDelegate appDelegate] showConversationViewController];
        if (!self.loginHandler) {
            self.loginHandler = [OTRXMPPLoginHandler new];
        }
        
        
        [super loginButtonPressed:nil];
        
    } else {
        [self showError:@"Login Unsuccessful" withMessage:[responseObject valueForKey:@"error_message"]];
        [self stopActivity];
    }
}

-(void)pushInviteViewController {
    [super pushInviteViewController];
}


//#pragma - mark Errors and Alert Views
//
//- (void)handleError:(NSError *)error
//{
//    //show xmpp erors, cert errors, tor errors, oauth errors.
//    if (error.code == OTRXMPPSSLError) {
//        NSData * certData = error.userInfo[OTRXMPPSSLCertificateDataKey];
//        NSString * hostname = error.userInfo[OTRXMPPSSLHostnameKey];
//        uint32_t trustResultType = [error.userInfo[OTRXMPPSSLTrustResultKey] unsignedIntValue];
//        
//        [self showCertWarningForCertificateData:certData withHostname:hostname trustResultType:trustResultType];
//    }
//    else {
//        [self handleXMPPError:error];
//    }
//}
//
//- (void)handleXMPPError:(NSError *)error
//{    
//    [self showAlertViewWithTitle:ERROR_STRING() message:XMPP_FAIL_STRING() error:error];
//}
//
//- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message error:(NSError *)error
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertAction * okButtonItem = [UIAlertAction actionWithTitle:OK_STRING() style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        UIAlertController * alertController = nil;
//        if (error) {
//            UIAlertAction * infoButton = [UIAlertAction actionWithTitle:INFO_STRING() style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                NSString * errorDescriptionString = [NSString stringWithFormat:@"%@ : %@",[error domain],[error localizedDescription]];
//                NSString *xmlErrorString = error.userInfo[OTRXMPPXMLErrorKey];
//                if (xmlErrorString) {
//                    errorDescriptionString = [errorDescriptionString stringByAppendingFormat:@"\n\n%@", xmlErrorString];
//                }
//                
//                if ([[error domain] isEqualToString:@"kCFStreamErrorDomainSSL"]) {
//                    NSString * sslString = [OTRXMPPError errorStringWithSSLStatus:(OSStatus)error.code];
//                    if ([sslString length]) {
//                        errorDescriptionString = [errorDescriptionString stringByAppendingFormat:@"\n%@",sslString];
//                    }
//                }
//                
//                
//                UIAlertAction * copyButtonItem = [UIAlertAction actionWithTitle:COPY_STRING() style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    NSString * copyString = [NSString stringWithFormat:@"Domain: %@\nCode: %ld\nUserInfo: %@",[error domain],(long)[error code],[error userInfo]];
//                    
//                    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
//                    [pasteBoard setString:copyString];
//                }];
//                
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:INFO_STRING() message:errorDescriptionString preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:okButtonItem];
//                [alert addAction:copyButtonItem];
//                [self presentViewController:alert animated:YES completion:nil];
//            }];
//            
//            alertController = [UIAlertController alertControllerWithTitle:title
//                                                                  message:message
//                                                           preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:okButtonItem];
//            [alertController addAction:infoButton];
//        }
//        else {
//            alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:okButtonItem];
//        }
//        
//        if (alertController) {
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//    });
//}
//
//
//- (void)showCertWarningForCertificateData:(NSData *)certData withHostname:(NSString *)hostname trustResultType:(SecTrustResultType)resultType {
//    
//    SecCertificateRef certificate = [OTRCertificatePinning certForData:certData];
//    NSString * fingerprint = [OTRCertificatePinning sha256FingerprintForCertificate:certificate];
//    NSString * message = [NSString stringWithFormat:@"%@\n\nSHA256\n%@",hostname,fingerprint];
//    
//    UIAlertController *certAlert = [UIAlertController alertControllerWithTitle:NEW_CERTIFICATE_STRING() message:nil preferredStyle:UIAlertControllerStyleAlert];
//    
//    if (![OTRCertificatePinning publicKeyWithCertData:certData]) {
//        //no public key not able to save because won't be able evaluate later
//        
//        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n\nX %@",PUBLIC_KEY_ERROR_STRING()]];
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle:OK_STRING() style:UIAlertActionStyleCancel handler:nil];
//        [certAlert addAction:action];
//    }
//    else {
//        if (resultType == kSecTrustResultProceed || resultType == kSecTrustResultUnspecified) {
//            //#52A352
//            message = [message stringByAppendingString:[NSString stringWithFormat:@"\n\n✓ %@",VALID_CERTIFICATE_STRING()]];
//        }
//        else {
//            NSString * sslErrorMessage = [OTRXMPPError errorStringWithTrustResultType:resultType];
//            message = [message stringByAppendingString:[NSString stringWithFormat:@"\n\nX %@",sslErrorMessage]];
//        }
//        
//        UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:REJECT_STRING() style:UIAlertActionStyleDestructive handler:nil];
//        [certAlert addAction:rejectAction];
//        
////        __weak __typeof__(self) weakSelf = self;
//        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:SAVE_STRING() style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            __typeof__(self) strongSelf = weakSelf;
//            [OTRCertificatePinning addCertificate:[OTRCertificatePinning certForData:certData] withHostName:hostname];
//            [[ZomAppDelegate appDelegate] showConversationViewController];
//        }];
//        [certAlert addAction:saveAction];
//    }
//    
//    certAlert.message = message;
//    
//    [self presentViewController:certAlert animated:YES completion:nil];
//}





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
