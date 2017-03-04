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


@interface ZomLoginViewController ()<UITextFieldDelegate, ZomCountryCodeDelegate>
@property (nonatomic, strong) VROChatAPIHandler *apiHandler;

@end

@implementation ZomLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        _textFieldEmail.placeholder = @"Country";
        [sender setTitle:@"Login By Email" forState:UIControlStateNormal];
    } else {
        _textFieldEmail.tag = 0;
        _textFieldEmail.placeholder = @"Email";
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
    //    if (self.txt_Email.text.length==0||self.txt_fullName.text.length==0||self.txt_Password.text.length==0||self.txt_confirmPassword.text.length==0) {
    //        return;
    //    }
    //    if (![self.txt_Password.text isEqualToString:self.txt_confirmPassword.text]) {
    //        return;
    //    }
    //    [self.apiHandler registerUserEmail:self.txt_Email.text fullName:self.txt_fullName.text andPassWord:self.txt_Password.text success:^(id responseObject) {
    //        NSLog(@"Account Created %@",responseObject);
    //    } failure:^(NSError *error) {
    //        NSLog(@"Error Occured: %@",[error localizedDescription]);
    //    }];
}


- (IBAction)buttonActionVerify:(UIButton *)sender {
    
}


- (IBAction)buttonActionResendOTP:(UIButton *)sender {
    
}

@end
