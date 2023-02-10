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
    func onLoadVideo(playerURL:[String])
}

class ViewTableViewController: CustomTableViewController {
    
    public weak var viewTableViewControllerDelegate:ViewTableViewControllerDelegate?
    var tableCell = [CustomCell]()
    let viewModel = ViewModel()
     
    override func viewDidLoad() {
        register.append("VideoItemTableViewCell")
        super.viewDidLoad()
         
        viewModel.fetchVideoItem { videoItem in
            for item in videoItem {
                let videoItemCell = VideoItemCustomCell(tableViewCell: VideoItemTableViewCell())
                videoItemCell.videoPlayer = item
                self.tableCell.append(videoItemCell)
            }
            self.tableView.reloadData()
        } error: { error in
            dump( error )
        }
         
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
        
        if tableCell[indexPath.row] is VideoItemCustomCell {
            
            let getCell = tableView.cellForRow(at: indexPath) as! VideoItemTableViewCell
            getCell.setupPlaying()
            
            let getCustomCell = tableCell[indexPath.row] as! VideoItemCustomCell
            
            viewTableViewControllerDelegate?.selectedVideo(playerURL: getCustomCell.videoPlayer?.urlPlayer ?? "")
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCell[indexPath.row].height
    }

}
