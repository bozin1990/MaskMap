//
//  MapItem.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/2.
//  Copyright © 2020 Bozin. All rights reserved.
//

import MapKit

class MapItem: NSObject, MKAnnotation {
    enum ItemType: UInt32 {
        case green = 0
        case orange = 1
        
        var image: UIImage {
            switch self {
            case .green:
                return #imageLiteral(resourceName: "man")
            case .orange:
                return #imageLiteral(resourceName: "woman")
            }
        }
    }
    
    let coordinate: CLLocationCoordinate2D
    let itemType: ItemType
    var image: UIImage { return itemType.image}
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.itemType = ItemType(rawValue: arc4random_uniform(2)) ?? .green
    }
    
}
