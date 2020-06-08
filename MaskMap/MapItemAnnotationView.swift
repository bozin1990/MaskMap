//
//  MapItemAnnotationView.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/2.
//  Copyright © 2020 Bozin. All rights reserved.
//

import MapKit

class MapItemAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            guard let mapItem = annotation as? MapItem else { return }
            
            clusteringIdentifier = "MapItem"
            image = mapItem.image
        }
    }
}
