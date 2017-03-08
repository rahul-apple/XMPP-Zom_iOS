//
//  ZomLoginViewController.h
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import <UIKit/UIKit.h>
#import <ACFloatingTextfield_Objc/ACFloatingTextField.h>
#import <TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h>
#import "Zom-Swift.h"

@interface ZomLoginViewController : OTRBaseLoginViewController

@property (nonatomic, assign) BOOL isFromSignupPage;

@property (strong, nonatomic) IBOutlet ACFloatingTextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet ACFloatingTextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *textFieldMobileNumber;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *textFieldCountryCode;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *textFieldOTP;


@property (weak, nonatomic) IBOutlet UIButton *buttonLoginByMobile;
@property (weak, nonatomic) IBOutlet UIView *viewMobileNumber;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UIView *viewOTP;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewMobileHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewMobileBottom;


- (IBAction)buttonActionLogin:(UIButton *)sender;
- (IBAction)buttonActionChangeType:(UIButton *)sender;
- (IBAction)buttonActionVerify:(UIButton *)sender;
- (IBAction)buttonActionChangeNumber:(UIButton *)sender;
- (IBAction)buttonActionResendOTP:(UIButton *)sender;

@end
