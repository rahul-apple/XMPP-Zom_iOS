//
//  ZomSignUpViewController.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "ZomSignUpViewController.h"
#import "VROChatAPIHandler.h"

@interface ZomSignUpViewController ()
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
@end
