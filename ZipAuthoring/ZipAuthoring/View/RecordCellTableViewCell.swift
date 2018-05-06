//
//  RecordCellTableViewCell.swift
//  ZipAuthoring
//
//  Created by xr on 5/3/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit

class RecordCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var checkImgView: UIImageView!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var item = RecordModel()
    var targetController: HomeViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(item: RecordModel) {
        self.item = item
        if item.is_play {
            self.playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        else {
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        
        self.checkImgView.isHidden = !item.is_transcribed
        self.dateLabel.text = TextUtils.getTimeStamp(item.date)
        self.filenameLabel.text = item.name
    }
    
    @IBAction func onPlayBtn(_ sender: Any) {
        if item.is_play {
            self.playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        else {
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
}
