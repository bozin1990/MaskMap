//
//  Post.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/10.
//  Copyright © 2020 Bozin. All rights reserved.
//

import Foundation

struct MaskData: Decodable {
    let features: [MaskList]
    
    struct MaskList: Decodable {
        let properties: Properties
        let geometry: Geometry
    }
    
    struct Properties: Decodable {
        let name: String
        let phone: String
        let address: String
        let maskAdult: Int
        let maskChild: Int
        let updated: Date
        let available: String
        let note: String
        let customNote: String
        let website: String
        let county: String
        let town: String
        let cunli: String
        let servicePeriods: String
        
    }
    struct Geometry: Decodable {
        let coordinates: [Double]
    }
}
