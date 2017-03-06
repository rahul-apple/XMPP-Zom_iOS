//
//  ZomSignUpViewController.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "ZomSignUpViewController.h"
#import "ZomCountryPickerViewController.h"
#import "UIViewController+ZomViewController.h"
#import "VROChatAPIHandler.h"
#import "ZomLoginViewController.h"

@interface ZomSignUpViewController ()<UITextFieldDelegate, ZomCountryCodeDelegate>
@property (nonatomic, strong) VROChatAPIHandler *apiHandler;
@end

@implementation ZomSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.apiHandler = [[VROChatAPIHandler alloc]init];
    _constraintViewMobileHeight.constant = 0;
    _constraintViewMobileBottom.constant = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNotifications];
}

#pragma mark - ZomCountryCodeDelegate Delegate
- (void)countryCodeSelectionCompleted:(NSDictionary *)dict
{
    NSString *string = dict[@"country_code"];
    NSArray *words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nospacestring = [words componentsJoinedByString:@""];
    
    _textFieldCountryCode.text = nospacestring;
    _txt_Email.text = dict[@"country_name"];
    [_textFieldCountryCode upadteTextField:_textFieldCountryCode.frame];
    [_txt_Email upadteTextField:_txt_Email.frame];
    [_txt_Email setTextFieldPlaceholderText:@"Country"] ;
}

#pragma mark - UITextField Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 111) {
        if (self.navigationController.topViewController == self) {
            [self.view endEditing:YES];
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
- (IBAction)createAccount:(UIButton *)sender {
    [self.view endEditing:NO];
    if (_buttonRegisterByMobile.tag == 0) {
        if (self.txt_Email.text.length==0||self.txt_fullName.text.length==0||self.txt_Password.text.length==0||self.txt_confirmPassword.text.length==0) {
            [self showWarning:@"Please fill all fields"];
            return;
        }
        if (![self isValidEmail:_txt_Email.text]) {
            [self showWarning:@"Please enter valid email"];
            return;
        }
        if (![self.txt_Password.text isEqualToString:self.txt_confirmPassword.text]) {
            [self showWarning:@"Passwords must be same"];
            return;
        }
        
        [self.apiHandler registerUserEmail:self.txt_Email.text fullName:self.txt_fullName.text andPassWord:self.txt_Password.text success:^(id responseObject) {
            if (![responseObject valueForKey:@"error"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showSuccess:@"Registration Successful" withMessage:@"Your account was registered with us successfully. You will need to confirm your email by clicking the Activation Link sent to your email."];
                    self.view.userInteractionEnabled = false;
                });
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:6.0];
            } else {
                [self showError:@"Registration Unsuccessful" withMessage:[responseObject valueForKey:@"error_message"]];
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    if ([[error localizedDescription] containsString:@"403"]) {
                        [self showError:@"Registration Unsuccessful" withMessage:@"Email already registered"];
                    } else {
                        [self showError:@"Registration Unsuccessful" withMessage:[error localizedDescription]];
                    }
                }
            });
        }];
    } else {
        if (self.txt_Email.text.length==0||self.txt_fullName.text.length==0||self.textFieldCountryCode.text.length==0||self.textFieldMobileNumber.text.length==0||self.txt_Password.text.length==0||self.txt_confirmPassword.text.length==0) {
            [self showWarning:@"Please fill all fields"];
            return;
        }
        if (![self isValidPhone:[NSString stringWithFormat:@"%@%@", _textFieldCountryCode.text, _textFieldMobileNumber.text]]) {
            [self showWarning:@"Please enter valid mobile number"];
            return;
        }
        if (![self.txt_Password.text isEqualToString:self.txt_confirmPassword.text]) {
            [self showWarning:@"Passwords must be same"];
            return;
        }
        [self.apiHandler registerUserMobile:_textFieldMobileNumber.text fullName:_txt_fullName.text password:_txt_Password.text andCountryCode:_textFieldCountryCode.text success:^(id responseObject) {
            if (![responseObject valueForKey:@"error"]) {
                ZomLoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZomLoginViewController"];
                loginController.isFromSignupPage = YES;
                [self.navigationController pushViewController:loginController animated:YES];
            } else {
                [self showError:@"Registration Unsuccessful" withMessage:[responseObject valueForKey:@"error_message"]];
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    if ([[error localizedDescription] containsString:@"403"]) {
                        [self showError:@"Registration Unsuccessful" withMessage:@"Mobile number already registered"];
                    } else {
                        [self showError:@"Registration Unsuccessful" withMessage:[error localizedDescription]];
                    }
                }
            });
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

- (IBAction)buttonActionChangeType:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.tag = sender.tag == 0 ? 1 : 0;
    
    _txt_Email.text = @"";
    _textFieldCountryCode.text = @"";
    _viewMobileNumber.hidden = sender.tag == 0;
    
    [self.view layoutIfNeeded];
    
    _constraintViewMobileHeight.constant = sender.tag == 1 ? 50.0 : 0;
    _constraintViewMobileBottom.constant = sender.tag == 1 ? 12.0 : 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        CGFloat height = CGRectGetMaxY([self.navigationController navigationBar].frame) + CGRectGetMaxY(_buttonRegisterByMobile.frame) + 24.0;
        if (height > self.view.frame.size.height) {
            _constraintViewHeight.constant = height;
        } else {
            _constraintViewHeight.constant = self.view.frame.size.height;
        }
        [_textFieldCountryCode upadteTextField:_textFieldCountryCode.frame];
        [_textFieldMobileNumber upadteTextField:_textFieldMobileNumber.frame];

    }];
    
    if (sender.tag == 1) {
        _txt_Email.tag = 111;
        [_txt_Email setTextFieldPlaceholderText:@"Country"] ;
        [sender setTitle:@"Register By Email" forState:UIControlStateNormal];
    } else {
        _txt_Email.tag = 0;
        [_txt_Email setTextFieldPlaceholderText:@"Email"];
        [sender setTitle:@"Register By Mobile" forState:UIControlStateNormal];
    }

}
@end
