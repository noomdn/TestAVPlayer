//
//  CustomViewController.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import UIKit

class CustomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
 
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
     
}
