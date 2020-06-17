//
//  PharmacyDetailViewController.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/17.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class PharmacyDetailViewController: UIViewController {

    var maskData: MaskData.MaskList?
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var childNumberLabel: UILabel!
    @IBOutlet weak var adultNumberLabel: UILabel!
    @IBOutlet weak var pharmacyAddressLabel: UILabel!
    @IBOutlet weak var pharmacyNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        getDetailData(maskData: maskData)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    func getDetailData(maskData: MaskData.MaskList?) {
        pharmacyNameLabel.text = maskData?.properties.name
        pharmacyAddressLabel.text = maskData?.properties.address
        adultNumberLabel.text = "\(maskData?.properties.maskAdult ?? 0)"
        childNumberLabel.text = "\(maskData?.properties.maskChild ?? 0)"
        availableLabel.text = maskData?.properties.available
        noteLabel.text = maskData?.properties.note
        print("11\(String(describing: availableLabel.text))")
    }
    
}
