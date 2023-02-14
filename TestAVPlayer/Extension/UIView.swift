//
//  UIView.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 14/2/2566 BE.
//

import Foundation
import UIKit

extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
