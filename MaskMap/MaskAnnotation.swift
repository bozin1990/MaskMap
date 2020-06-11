//
//  MaskAnnotation.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/4/15.
//  Copyright © 2020 Bozin. All rights reserved.
//
import MapKit

class MaskAnnotation: NSObject, MKAnnotation  {
    var coordinate: CLLocationCoordinate2D
    var mask: Mask?
    var title: String? {
        mask?.name
    }
    
    init(feature: MKGeoJSONFeature) {
        coordinate = feature.geometry[0].coordinate
        guard let data = feature.properties else { return }
        let decoder = JSONDecoder()
        //        底線欄位名稱轉換
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let timeString = try decoder.singleValueContainer().decode(String.self)
            return DateFormatter.customFormatter.date(from: timeString) ?? Date()
        })
        mask = try? decoder.decode(Mask.self, from: data)
    }
    
}

extension DateFormatter {
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }()
}
