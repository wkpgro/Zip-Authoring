//
//  UserModel.swift
//  ZipAuthoring
//
//  Created by xr on 5/2/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit

class UserModel: NSObject, NSCoding {

    var password = ""
    var email = ""
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(password, forKey: "password")
        aCoder.encode(email, forKey: "email")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()

        self.password = aDecoder.decodeObject(forKey: "password") as? String ?? ""
        self.email = aDecoder.decodeObject(forKey: "email") as? String ?? ""
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    override init() {
        super.init()
    }
}
