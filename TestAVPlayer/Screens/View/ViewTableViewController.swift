//
//  ViewTableViewController.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import UIKit
import Kingfisher

protocol ViewTableViewControllerDelegate:AnyObject {
    func selectedVideo(playerURL:String)
    func onLoadVideo(playerURLs:[String])
}

class ViewTableViewController: CustomTableViewController {
    
    public weak var viewTableViewControllerDelegate:ViewTableViewControllerDelegate?
    var defaultSelected = 0
    var tableCell = [CustomCell]()
    let viewModel = ViewModel()
     
    override func viewDidLoad() {
        register.append("VideoItemTableViewCell")
        super.viewDidLoad()
         
        viewModel.fetchVideoItem { videoItem in
            var playerUrls = [String]()
            for item in videoItem {
                playerUrls.append(item.urlPlayer)
                let videoItemCell = VideoItemCustomCell(tableViewCell: VideoItemTableViewCell())
                videoItemCell.videoPlayer = item
                self.tableCell.append(videoItemCell)
            }//end loop for
            self.viewTableViewControllerDelegate?.onLoadVideo(playerURLs: playerUrls)
            self.tableView.reloadData()
        } error: { error in
            dump( error )
        }
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DispatchQueue.main.asyncAfter(wallDeadline: .now()+2, execute: { [self] in
//            self.tableView(tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
//        })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableCell.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableCell[indexPath.row]
        if customCell.tableViewCell is VideoItemTableViewCell {
            return viewModel.renderTableViewCell(tableView, cellForRowAt: indexPath, customCell: customCell)
        }
        return UITableViewCell()
    }
     
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableCell[indexPath.row] is VideoItemCustomCell {
            let getCell = tableView.cellForRow(at: indexPath) as! VideoItemTableViewCell
            getCell.removePlaying()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("== ViewTableViewController ==")
        print(indexPath)
        dump( tableCell.count )
        if tableCell.indices.contains(indexPath.row) {
            print("OK..")
            
            if tableCell[indexPath.row] is VideoItemCustomCell {
                let getCell = tableView.cellForRow(at: indexPath) as! VideoItemTableViewCell
                getCell.setupPlaying()
                
                let getCustomCell = tableCell[indexPath.row] as! VideoItemCustomCell
                
                viewTableViewControllerDelegate?.selectedVideo(playerURL: getCustomCell.videoPlayer?.urlPlayer ?? "")
            }
        } else {
            print("not found item...")
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCell[indexPath.row].height
    }

}

