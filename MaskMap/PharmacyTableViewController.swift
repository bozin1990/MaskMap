//
//  PharmacyTableViewController.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/10.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class PharmacyTableViewController: UITableViewController, UISearchBarDelegate {
    
    var distances: Distance?
    var maskDatas = [MaskData.MaskList]()
    var searchMaskDatas = [MaskData.MaskList]()
    var search = false
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "請輸入地址關鍵字查詢"
        //        titleView的元件換成searchBar
        navigationItem.titleView = searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        //        如果搜尋條件為空字串，就顯示原始資料；否則就顯示搜尋後結果
        if text == "" {
            search = false
        } else {
            //            搜尋原始資料內有無包含關鍵字(不區別大小寫)
            searchMaskDatas = maskDatas.filter({ (maskList) -> Bool in
                return maskList.properties.address.uppercased().contains(text.uppercased())
            })
            search = true
        }
        tableView.reloadData()
    }
    //    點擊鍵盤上的Search按鈕時將鍵盤隱藏
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PharmacyDetailViewController") as! PharmacyDetailViewController
        if search {
            let maskData = searchMaskDatas[indexPath.row]
            controller.maskData = maskData
            print("1234 \(maskData)")
        } else {
            let maskData = maskDatas[indexPath.row]
            controller.maskData = maskData
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if search {
            return searchMaskDatas.count
        } else {
            return maskDatas.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PharmacyTableViewCell", for: indexPath) as! PharmacyTableViewCell
        
        if search {
            let maskData = searchMaskDatas[indexPath.row]
            cell.update(maskData: maskData)
            
        } else {
            let maskData = maskDatas[indexPath.row]
            cell.update(maskData: maskData)
            
        }
        
        return cell
    }
    
}

extension PharmacyTableViewController:MapViewControllerDelegate {
    func getDistance(distanceData: Distance?) {
        if let distances = distanceData {
            self.distances = distances
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func didFinishLoadMaskData(maskData: [MaskData.MaskList]?) {
        if let passData = maskData {
            self.maskDatas = passData
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
