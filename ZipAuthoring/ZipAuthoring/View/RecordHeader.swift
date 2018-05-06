//
//  RecordHeader.swift
//  ZipAuthoring
//
//  Created by xr on 5/3/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit

class RecordHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var dateLabel: UILabel!
    
    func setupHeaderView(date: Date) {
        dateLabel.text = TextUtils.getDateString(date: date, format: Global.DATE_MMMM_YYYY)
    }
}
