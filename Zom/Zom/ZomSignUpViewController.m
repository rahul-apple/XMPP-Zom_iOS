//
//  ZomSignUpViewController.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "ZomSignUpViewController.h"
#import "ZomCountryPickerViewController.h"
#import "VROChatAPIHandler.h"

@interface ZomSignUpViewController ()<UITextFieldDelegate, ZomCountryCodeDelegate>
@property (nonatomic, strong) VROChatAPIHandler *apiHandler;
@end

@implementation ZomSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.apiHandler = [[VROChatAPIHandler alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ZomCountryCodeDelegate Delegate
- (void)countryCodeSelectionCompleted:(NSDictionary *)dict
{
    NSString *string = dict[@"country_code"];
    NSArray *words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nospacestring = [words componentsJoinedByString:@""];
    
    _textFieldCountryCode.text = nospacestring;
    _txt_Email.text = dict[@"country_name"];
}

#pragma mark - UITextField Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 111) {
        [self.view endEditing:YES];
        ZomCountryPickerViewController *countryPickerController = (ZomCountryPickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ZomCountryPickerViewController"];
        countryPickerController.delegate = self;
        [self.navigationController pushViewController:countryPickerController animated:YES];
        return NO;
    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}
- (IBAction)createAccount:(id)sender {
    if (self.txt_Email.text.length==0||self.txt_fullName.text.length==0||self.txt_Password.text.length==0||self.txt_confirmPassword.text.length==0) {
        return;
    }
    if (![self.txt_Password.text isEqualToString:self.txt_confirmPassword.text]) {
        return;
    }
    [self.apiHandler registerUserEmail:self.txt_Email.text fullName:self.txt_fullName.text andPassWord:self.txt_Password.text success:^(id responseObject) {
        NSLog(@"Account Created %@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"Error Occured: %@",[error localizedDescription]);
    }];
}

- (IBAction)buttonActionChangeType:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.tag = sender.tag == 0 ? 1 : 0;
    
    _txt_Email.text = @"";
    _textFieldCountryCode.text = @"";
    _viewMobileNumber.hidden = sender.tag == 0;
    _txt_confirmPassword.hidden = sender.tag == 1;
    _txt_Password.hidden = sender.tag == 1;
    
    [self.view layoutIfNeeded];

    _constraintTextFieldHeight.constant = sender.tag == 0 ? 50 : 0;
    _constraintTextFieldBottom.constant = sender.tag == 0 ? 12 : 0;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if (sender.tag == 1) {
        _txt_Email.tag = 111;
        _txt_Email.placeholder = @"Country";
        [sender setTitle:@"Register By Email" forState:UIControlStateNormal];
    } else {
        _txt_Email.tag = 0;
        _txt_Email.placeholder = @"Email";
        [sender setTitle:@"Register By Mobile" forState:UIControlStateNormal];
    }

}
@end
