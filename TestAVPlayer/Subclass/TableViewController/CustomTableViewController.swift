//
//  CustomTableViewController.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import UIKit

class CustomTableViewController: UITableViewController {
    
    var register = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for identifier in register {
            tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
        
    }
    
    
    /**
     Notification center for post observer.
     */
    public func postObserver(name aName: NotificationName, userInfo aUserInfo: [AnyHashable : Any]? = nil){
        NotificationCenter.default.post(name: Notification.Name(aName.rawValue), object: nil , userInfo: aUserInfo)
    }
    
    /**
     Notfication center for add observer.
     */
    public func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NotificationName){
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: Notification.Name(aName.rawValue), object: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectedBackgroundView = UIView()
    }
    

}
