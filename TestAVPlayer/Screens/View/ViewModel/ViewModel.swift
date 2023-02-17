//
//  ViewModel.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import Foundation
import UIKit
import AVKit

class ViewModel {
    
    //render viode player
    func renderVideoPlayer(playerUrl:String,complation:@escaping(AVPlayer)->Void,onError:@escaping(String)->Void){
        let group = DispatchGroup()
        group.enter()
        guard let url = URL(string: playerUrl) else {
            onError("Error URL")
            return
        }
        
        let asset = AVAsset(url: url)
        
        asset.loadMetadata(for: .hlsMetadata) { metaDataItems, error in
            guard error == nil else {
                onError(error!.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                group.leave()
            }
        }

        let playItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playItem)
        
        let playView = AVPlayerLayer()
        playView.contentsGravity = .resizeAspect
        playView.needsDisplayOnBoundsChange = true
        
        group.notify(queue: DispatchQueue.main) {
            complation(player)
        }
    }
    
    // load video from api
    func fetchVideoItem(complation:@escaping([VideoPlayer])->Void ,error:@escaping(String)->Void){
        APIService.shared.onLoadVideoItem { result in
            switch result {
            case .success(let success):
                complation(success)
            case .failure(let failure):
                error(failure.localizedDescription)
            }
        }
    }
    
    
    func renderCurrentTimeframe(currentTime: CMTime) -> String{
        let mins = CMTimeGetSeconds(currentTime) / 60
        let secs = CMTimeGetSeconds(currentTime).truncatingRemainder(dividingBy: 60)
        
        let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return ""
        }
        return "\(minsStr):\(secsStr)"
    }
    
    
    // render table view cell
    func renderTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ,customCell:CustomCell) -> UITableViewCell {
        let getCustomCell = customCell as! VideoItemCustomCell
        let cell = tableView.dequeueReusableCell(withIdentifier: customCell.nibName, for: indexPath) as! VideoItemTableViewCell
        cell.selectedBackgroundView = UIView()
        cell.videoPlayerNameLabel.text = getCustomCell.videoPlayer?.name
        cell.videoPlayerImageView.onLoad(url: URL(string: getCustomCell.videoPlayer!.image)!)
         
        return cell
    }
    
}
