//
//  RecordModel.swift
//  ZipAuthoring
//
//  Created by xr on 5/3/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit

class RecordModel: NSObject, NSCoding {

    var name = ""
    var date = Date()
    var is_transcribed = false
    var is_play = false
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.is_transcribed, forKey: "is_transcribed")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
    }
    
    init(name: String, date: Date, is_transcribed: Bool = false) {
        self.name = name
        self.date = date
        self.is_transcribed = is_transcribed
        self.is_play = false
    }
    
    override init() {
        super.init()
    }
}
