//
//  LoginViewController.swift
//  ZipAuthoring
//
//  Created by xr on 5/2/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit

import AWSDynamoDB
import AWSCognitoIdentityProvider
import JGProgressHUD
import SwiftHash

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var m_forgotBtn: UIButton!
    @IBOutlet weak var m_username: UITextField!
    @IBOutlet weak var m_password: UITextField!
    
    var progressHUD: JGProgressHUD?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
//        let identityId = AWSIdentityManager.default().identityId
//
        self.m_username.text = "will.do14@hotmail.com"
        self.m_password.text = "abcABC!@#123"
        self.setupView()
    }
    
    //MARK: - UI
    func setupView() {
        let text = "Forgot Password"
        let text_range = NSRange(location: 0, length: text.count)
        let attributtedString = NSMutableAttributedString(string: text)
        attributtedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15.0), range: text_range)
        attributtedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: text_range)
        attributtedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: text_range)
        attributtedString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.black, range: text_range)
        self.m_forgotBtn.setAttributedTitle(attributtedString, for: .normal)
        self.m_forgotBtn.setAttributedTitle(attributtedString, for: .selected)
    }
    
    //MARK: - Actions
    @IBAction func onLogin(_ sender: Any) {
//        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        self.navigationController?.pushViewController(homeVC, animated: true)
        if self.validate() {
            let email = self.m_username.text!
            let password = MD5(self.m_password.text!)
            
            self.m_username.resignFirstResponder()
            self.m_password.resignFirstResponder()
            
            self.showProgressHUB("Login...")
            
            let emailAttr = AWSCognitoIdentityUserAttributeType()
            emailAttr?.name = "email"
            emailAttr?.value = email
            
            let pool = AWSCognitoIdentityUserPool.default()
            let username = email.lowercased().replacingOccurrences(of: "@", with: "_")
            let aws_user = pool.getUser(username)
            
            
            aws_user.getSession(username, password: password, validationData: [emailAttr!]).continueWith(block: { [weak self] (task: AWSTask) -> AnyObject? in
                
                guard let strongSelf = self else {
                    DispatchQueue.main.async {
                        self?.dismissProgressHUD()
                    }
                    return nil
                }
                
                if let error = task.error as NSError? {
                    DispatchQueue.main.async {
                        strongSelf.dismissProgressHUD()
                        
                        if error.userInfo["__type"] as? String == "UserNotConfirmedException" {
                            DispatchQueue.global().async {
                                aws_user.resendConfirmationCode()
                            }
                            
                            let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "ActivityViewController") as! ActivityViewController
                            vc.b_verificateType = false // no forgot
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                        else {
                            print("AWS Error Type: - \(error.userInfo["__type"] as? String ?? "AWS ErrorType")")
                            print("AWS Error Message: - \(error.userInfo["message"] as? String ?? "AWS ErrorMSG")")
                            let msg = "\(error.userInfo["message"] as? String ?? "You can't access Server.")"
                            UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: msg)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        strongSelf.performSegue(withIdentifier: "ToHome", sender: nil)
                    }
                    
//                    let objectMapper = AWSDynamoDBObjectMapper.default()
//                    let userid = email.components(separatedBy: "@").first
//
//                    objectMapper.load(User.self, hashKey: userid!, rangeKey: username) { (response: AWSDynamoDBObjectModel?, error: Error?) in
//                        DispatchQueue.main.async {
//                            strongSelf.dismissProgressHUD()
//                            if error != nil {
//                                print(error?.localizedDescription ?? "123")
//                                UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: (error?.localizedDescription))
//                            }
//                            else {
//                                let table = response as? User
//                                if table != nil {
//                                    let app_user = UserModel(email: "", password: "")
//                                    app_user.email = (table?._email)!
//                                    app_user.password = table!._password!
//                                    SharedManager.saveObjectDataToNSUserDefault(saveObject: app_user, forKey: Global.KEY_APP_USER)
//                                    strongSelf.performSegue(withIdentifier: "ToHome", sender: nil)
//                                }
//                                else {
//                                    // email address is case-sensitive - error = nil response = nil table = nil
//                                    UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: "Authenticate failure!")
//                                }
//                            }
//                        }
//                    }
                }
                
                return nil
            })
        }
        else {
            UIManager.showAlertViewController(targetVC: self, title: "Error", description: "Incorrect username or password")
        }
    }
    
    func validate() -> Bool {
        if TextUtils.isEmpty(self.m_username.text) {
            return false
        }
        
        if TextUtils.isEmpty(self.m_password.text) {
            return false
        }
        return true
    }
    
    func showProgressHUB(_ title: String) -> Void {
        if self.progressHUD == nil {
            //            self.progressHUD = JGProgressHUD(style: .dark)
        }
        else {
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
    
    func showTextHUB(_ title: String) {
        if self.progressHUD == nil {
            //            self.progressHUD = JGProgressHUD(style: .dark)
        }
        else {
            self.progressHUD = nil
        }
        
        self.progressHUD = JGProgressHUD(style: .dark)
        
        if (self.progressHUD?.isVisible) == false {
            self.progressHUD?.textLabel.text = title
            self.progressHUD?.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.progressHUD?.show(in: self.view)
        }
        else {
            self.progressHUD?.textLabel.text = title
            self.progressHUD?.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
}
