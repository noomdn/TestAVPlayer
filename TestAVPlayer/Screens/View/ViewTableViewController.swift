//
//  ViewTableViewController.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import UIKit
import Kingfisher

protocol ViewTableViewControllerDelegate:AnyObject {
    func onLoadPlayerItem(playerURLs:[String])
    func selectedVideo(playerURL:String ,indexPath:Int)
}

class ViewTableViewController: CustomTableViewController {
    
    public weak var viewTableViewControllerDelegate:ViewTableViewControllerDelegate?
    var oldSelected = 0
    var currentSelected = 0
    var isFirstStart = false
    var tableCell = [CustomCell]()
    let viewModel = ViewModel()
     
    override func viewDidLoad() {
        register.append("VideoItemTableViewCell")
        super.viewDidLoad()
        
        // notification center
        addObserver(self, selector: #selector(didChangeObserver), name: .change)
        addObserver(self, selector: #selector(didNextObserver), name: .next)
        addObserver(self, selector: #selector(didPrevObserver), name: .previos)
        
        // onload api
        viewModel.fetchVideoItem { videoItem in
            var playerUrls = [String]()
            for item in videoItem {
                playerUrls.append(item.urlPlayer)
                let videoItemCell = VideoItemCustomCell(tableViewCell: VideoItemTableViewCell())
                videoItemCell.videoPlayer = item
                self.tableCell.append(videoItemCell)
            }//end loop for
            
            self.viewTableViewControllerDelegate?.onLoadPlayerItem(playerURLs: playerUrls)
             
            // reload
            self.tableView.reloadData()
            
            // default selected
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            }
            
            // is first start
            self.isFirstStart = true
            
        } error: { error in
            dump( error )
        }
    }
    
    @objc func didNextObserver(sender:Notification){
        guard let userInfo = sender.userInfo else { return }
        if let row = userInfo["row"] as? Int {
            
            self.tableView(tableView, didDeselectRowAt: IndexPath(row: oldSelected, section: 0))
            
            self.tableView(tableView, didSelectRowAt: IndexPath(row: row, section: 0))
        }
    }
    
    @objc func didPrevObserver(sender:Notification){
        guard let userInfo = sender.userInfo else { return }
        if let row = userInfo["row"] as? Int {
            self.tableView(tableView, didDeselectRowAt: IndexPath(row: oldSelected, section: 0))
            self.tableView(tableView, didSelectRowAt: IndexPath(row: row, section: 0))
        }
    }
    
    @objc func didChangeObserver(sender:Notification){
        //guard let userInfo = sender.userInfo else { return }
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableCell.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableCell[indexPath.row]
        if customCell.tableViewCell is VideoItemTableViewCell {
            
            let cell = viewModel.renderTableViewCell(tableView, cellForRowAt: indexPath, customCell: customCell) as! VideoItemTableViewCell
            return cell
        }
        return UITableViewCell()
    }
     
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is VideoItemTableViewCell {
            let getCell = tableView.cellForRow(at: indexPath) as! VideoItemTableViewCell
            getCell.removePlaying()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableCell.indices.contains(indexPath.row) {
            if tableCell[indexPath.row] is VideoItemCustomCell {
                let getCell = tableView.cellForRow(at: indexPath) as! VideoItemTableViewCell
                getCell.setupPlaying()
                
//                if isFirstStart == true {
//                    self.isFirstStart = false
//                    self.tableView(self.tableView, didDeselectRowAt: IndexPath(row: 0, section: 0) )
//                }
//
                // save the selected index
                oldSelected = indexPath.row
                
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                
                let getCustomCell = tableCell[indexPath.row] as! VideoItemCustomCell
                viewTableViewControllerDelegate?.selectedVideo(playerURL: getCustomCell.videoPlayer?.urlPlayer ?? "" ,indexPath: indexPath.row)
            }
        }
    }
     
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCell[indexPath.row].height
    }

}

