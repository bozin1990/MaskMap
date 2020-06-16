//
//  PharmacyDetailTableViewCell.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/17.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class PharmacyDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var availableTextView: UITextView!
    @IBOutlet weak var childNumberLabel: UILabel!
    @IBOutlet weak var adultNumberLabel: UILabel!
    @IBOutlet weak var pharmacyAddressLabel: UILabel!
    @IBOutlet weak var pharmacyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func getDetailData(maskData: MaskData.MaskList) {
        pharmacyNameLabel.text = maskData.properties.name
        pharmacyAddressLabel.text = maskData.properties.address
        adultNumberLabel.text = String(maskData.properties.maskAdult)
        childNumberLabel.text = String(maskData.properties.maskChild)
        availableTextView.text = maskData.properties.available
        noteLabel.text = maskData.properties.note
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
