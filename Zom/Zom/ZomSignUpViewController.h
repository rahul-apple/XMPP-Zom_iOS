//
//  ZomSignUpViewController.h
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import <UIKit/UIKit.h>
#import <ACFloatingTextfield_Objc/ACFloatingTextField.h>
@interface ZomSignUpViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet ACFloatingTextField *txt_fullName;
@property (strong, nonatomic) IBOutlet ACFloatingTextField *txt_Email;
@property (strong, nonatomic) IBOutlet ACFloatingTextField *txt_Password;
@property (strong, nonatomic) IBOutlet ACFloatingTextField *txt_confirmPassword;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *textFieldMobileNumber;
@property (weak, nonatomic) IBOutlet ACFloatingTextField *textFieldCountryCode;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextFieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextFieldBottom;


@property (weak, nonatomic) IBOutlet UIButton *buttonRegisterByMobile;
@property (weak, nonatomic) IBOutlet UIView *viewMobileNumber;


- (IBAction)createAccount:(id)sender;
- (IBAction)buttonActionChangeType:(UIButton *)sender;



@end
