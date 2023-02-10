//
//  VideoItemTableViewCell.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import UIKit

class VideoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var videoPlayerImageView: UIImageView!
    @IBOutlet weak var videoPlayerNameLabel: UILabel!
    @IBOutlet weak var videoPlayerDateLabel: UILabel!
    @IBOutlet weak var videoPlayerDescTextView: UITextView!
    @IBOutlet weak var optionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        videoPlayerImageView.backgroundColor = .systemGray
        videoPlayerImageView.contentMode = .scaleAspectFill
        
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 22.0)
        imgConfig.applying(UIImage.SymbolConfiguration(weight: .regular))
        let img = UIImage(systemName: "ellipsis",withConfiguration: imgConfig)
        
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.background.image = img
        btnConfig.background.imageContentMode = .center
        btnConfig.background.backgroundColor = .clear
        optionButton.configuration = btnConfig
        
    }
     
    public func setupPlaying(){
        // set playing background color
        self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 173/255, alpha: 0.5)
        // set playing image
        let playImage = UIImageView(image: UIImage(systemName: "play.fill"))
        playImage.tintColor = .systemYellow
        playImage.translatesAutoresizingMaskIntoConstraints = false
        self.videoPlayerImageView.addSubview(playImage)
        playImage.widthAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        playImage.heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        playImage.centerXAnchor.constraint(equalTo:self.videoPlayerImageView.centerXAnchor).isActive = true
        playImage.centerYAnchor.constraint(equalTo: self.videoPlayerImageView.centerYAnchor).isActive = true
    }
    
    public func removePlaying(){
        for subview in self.videoPlayerImageView.subviews {
            subview.removeFromSuperview()
        }
        self.backgroundColor = .white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
