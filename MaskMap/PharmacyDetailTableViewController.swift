//
//  PharmacyDetailTableViewController.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/17.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class PharmacyDetailTableViewController: UITableViewController {

    var maskDatas = [MaskData.MaskList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PharmacyDetailTableViewCell", for: indexPath) as! PharmacyDetailTableViewCell
        let maskData = maskDatas[indexPath.row]
        cell.getDetailData(maskData: maskData)

        return cell
    }
    
}

extension PharmacyDetailTableViewController: ViewControllerDelegate {
    func didFinishLoadMaskData(maskData: [MaskData.MaskList]?) {
          if let passData = maskData {
                  self.maskDatas = passData
        }
    }
    
    func getDistance(distanceData: Distance?) {
        
    }
    
    
}
