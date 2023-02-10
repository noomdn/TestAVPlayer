//
//  CustomCell.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import Foundation
import UIKit

class CustomCell {
    var nibName:String!
    var tableViewCell:UITableViewCell!
    var height = CGFloat(50.0)
    
    init(tableViewCell: UITableViewCell!) {
        self.tableViewCell = tableViewCell
        
        switch tableViewCell {
        case is VideoItemTableViewCell:
            nibName = "VideoItemTableViewCell"
            height = CGFloat(150.0)
        break
        default:
            fatalError("Error:Not found The Nib Name")
            break
        }
    }
    
    
    
}
