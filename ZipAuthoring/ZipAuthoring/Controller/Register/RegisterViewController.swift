//
//  RegisterViewController.swift
//  ZipAuthoring
//
//  Created by xr on 5/2/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit
import JGProgressHUD
import AWSDynamoDB
import AWSCognitoIdentityProvider
import SwiftHash

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmTxtField: UITextField!
    
    
    var progressHUD: JGProgressHUD?
    
    var new_user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTxtField.text = "will.do14@hotmail.com"
        self.passwordTxtField.text = "abcABC!@#123"
        self.confirmTxtField.text = "abcABC!@#123"
    }

    @IBAction func onRegister(_ sender: Any) {
        var message = ""
        var is_validate = false
        
        if TextUtils.isEmpty(emailTxtField.text) {
            message = "Please input your email"
        } else if TextUtils.isEmpty(passwordTxtField.text) {
            message = "Please input password"
        } else if TextUtils.isEmpty(confirmTxtField.text) {
            message = "Please confirm your password"
        } else if passwordTxtField.text != confirmTxtField.text {
            message = "Incorrect password"
        } else {
            is_validate = true
        }
        
        if is_validate == true {
            self.new_user = UserModel(email: self.emailTxtField.text!, password: self.passwordTxtField.text!)
            self.registerPool()
        }
        else {
            UIManager.showAlertViewController(targetVC: self, title: "Error", description: message)
        }
    }
    
    func registerPool() {
        
        self.showProgressHUB("Loading...")
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        let email = AWSCognitoIdentityUserAttributeType()
        email?.name = "email"
        email?.value = self.new_user.email
        attributes.append(email!)
        
        let password = MD5(self.new_user.password)
        
        let username = email?.value?.lowercased().replacingOccurrences(of: "@", with: "_")

        AWSCognitoIdentityUserPool.default().signUp(username!, password: password, userAttributes: attributes, validationData: nil).continueWith{[weak self] (task: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> AnyObject? in
            
            guard let strongSelf = self else { return nil }

            DispatchQueue.main.async(execute: {
                
                self?.dismissProgressHUD()
                if let error = task.error as NSError? {
                    print(error.userInfo["__type"] ?? "ddd")
                    let type = error.userInfo["__type"] as? String ?? "Error"
                    var msg = ""
                    
                    if type == "InvalidPasswordException" {
                        msg = "Password must be written Uppercase letters, Lowercase letters, Special characters, Numbers, at least 8 charaters"
                    }
                    else {
                        msg = error.userInfo["message"] as? String ?? "Error"
                    }
                    
                    UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: msg)
                    
//                    print("AWS Log - \(error.userInfo["__type"] ?? "AWS UnknownError")")
//                    print("AWS Log - \(msg)")
                    return
                }
                
                if let result = task.result as AWSCognitoIdentityUserPoolSignUpResponse? {

//                    m_dataManager.setUserRegistered(false)
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        // move to e-mail varification screen to verify your email
                        UIManager.showAlertViewController(targetVC: strongSelf, title: "Success", description: "Conffin sent you verification code from support@conffin.com", okAction: { (okAction) in
                            SharedManager.saveObjectDataToNSUserDefault(saveObject: strongSelf.new_user, forKey: Global.KEY_APP_USER)
                            
//                            let objectMapper = AWSDynamoDBObjectMapper.default()
//                            let model = User()
//                            model?._email = strongSelf.new_user.email
//                            model?._password = strongSelf.new_user.password
//
//                            objectMapper.save(model!).continueWith(block: { (task: AWSTask<AnyObject>!) -> Any? in
//                                DispatchQueue.main.async {
//                                    strongSelf.dismissProgressHUD()
//
//                                    if let error = task.error as NSError? {
//                                        UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: "\(error.localizedDescription)")
//                                    }
//                                    else {
//                                        strongSelf.performSegue(withIdentifier: "FromActiveToHome", sender: nil)
//                                    }
//                                }
//
//                                return nil
//                            })
                            
                            strongSelf.performSegue(withIdentifier: "ToActivate", sender: nil)
                        }, okActionTitle: "Ok", isVisiableCancel: false)
                    } else {
                        UIManager.showAlertViewController(targetVC: strongSelf, title: "Registration Complete", description: "Registeration was succcessful")
                    }
                }
            })
            
            return nil
        }
        
    }
    
    func showProgressHUB(_ title: String) -> Void {
        if self.progressHUD != nil {
            self.progressHUD = nil
        }
        
        self.progressHUD = JGProgressHUD(style: .dark)
        
        if (self.progressHUD?.isVisible) == false {
            self.progressHUD?.textLabel.text = title
            self.progressHUD?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            self.progressHUD?.show(in: self.view)
        }
    }
    
    func dismissProgressHUD() -> Void {
        if self.progressHUD != nil {
            if (self.progressHUD?.isVisible)! {
                self.progressHUD?.dismiss()
            }
        }
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
