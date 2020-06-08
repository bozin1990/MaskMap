//
//  ClusterAnnotationView.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/6/2.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import MapKit

final class ClusterAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultHigh
            
            let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
            image = UIGraphicsImageRenderer.image(for: cluster.memberAnnotations, in: rect)
        }
    }
}

