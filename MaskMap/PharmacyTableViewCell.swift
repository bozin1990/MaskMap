//
//  PharmacyTableViewCell.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/10.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class PharmacyTableViewCell: UITableViewCell {

    @IBOutlet weak var pharmacyAddress: UILabel!
    @IBOutlet weak var pharmacyName: UILabel!
    var maskData: MaskData.MaskList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(maskData: MaskData.MaskList) {
        pharmacyName.text = maskData.properties.name
        pharmacyAddress.text = maskData.properties.address
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
