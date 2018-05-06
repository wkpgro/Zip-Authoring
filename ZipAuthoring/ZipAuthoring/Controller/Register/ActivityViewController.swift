//
//  ActivityViewController.swift
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


class ActivityViewController: UIViewController {

    var app_user: UserModel?
    var progressHUD: JGProgressHUD?
    
    @IBOutlet weak var activityTxtField: UITextField!
    var b_verificateType = false // Activate Type,  true -> forgot.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.app_user = SharedManager.loadObjectDataToNSUserDefault(forKey: Global.KEY_APP_USER) as? UserModel ?? nil
    }
    
    @IBAction func onActivityBtn(_ sender: Any) {
        if self.app_user == nil {
            print("App user nil")
            return
        }
        
        if TextUtils.isEmpty(self.activityTxtField.text) {
            UIManager.showAlertViewController(targetVC: self, title: "Error", description: "Please input verification code")
            return
        }
        
        let username = self.app_user?.email.lowercased().replacingOccurrences(of: "@", with: "_")
        
        let pool = AWSCognitoIdentityUserPool.default()
        let aws_user = pool.getUser(username!)
        
        let code_txt = self.activityTxtField.text!
        
        
        aws_user.confirmSignUp(code_txt, forceAliasCreation: false).continueWith(block: { [weak self] (task: AWSTask) -> AnyObject? in
            
            guard let strongSelf = self else { return nil }
            
            if let error = task.error as NSError? {
                DispatchQueue.main.async {
                    strongSelf.dismissProgressHUD()
                    UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: (error.userInfo["message"] as? String ?? ""))
                }
            }
            else {

                UIManager.showAlertViewController(targetVC: strongSelf, title: "Success", description: "Your email is conformed!", okAction: { (okAction) in
                    strongSelf.performSegue(withIdentifier: "FromActiveToHome", sender: nil)
                }, okActionTitle: "OK", isVisiableCancel: false)
//                let objectMapper = AWSDynamoDBObjectMapper.default()
//                let model = User()
//                model?._userId = username
//                model?._email = strongSelf.app_user?.email
//                model?._password = MD5((strongSelf.app_user?.password)!)
//
//                objectMapper.save(model!).continueWith(block: { (task: AWSTask<AnyObject>!) -> Any? in
//                    DispatchQueue.main.async {
//                        strongSelf.dismissProgressHUD()
//
//                        if let error = task.error as NSError? {
//                            UIManager.showAlertViewController(targetVC: strongSelf, title: "Error", description: (error.userInfo["message"] as? String ?? ""))
//                        }
//                        else {
//                            strongSelf.performSegue(withIdentifier: "FromActiveToHome", sender: nil)
//                        }
//                    }
//
//                    return nil
//                })
            }
            
            return nil
        })
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
    
    func showTextHUB(_ title: String) {
        if self.progressHUD != nil {
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
}

extension ActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
