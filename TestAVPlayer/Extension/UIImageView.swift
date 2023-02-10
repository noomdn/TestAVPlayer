//
//  UIImageView.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func onLoad(url:URL){
        self.kf.setImage(
            with: url ,
            placeholder: UIImage(named: "placeholder"),
            options: [.cacheOriginalImage ,
                      .transition(.fade(0.25))
                    ]
        )
    }
}
