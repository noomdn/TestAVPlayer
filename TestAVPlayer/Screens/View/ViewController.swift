//
//  ViewController.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 6/2/2566 BE.
//

import UIKit
import AVFoundation
import AVKit
  
// video: https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4
// video: https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8

class ViewController: CustomViewController ,AVPlayerViewControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    var playUrlDefault = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8"
    
     var player: AVPlayer?
    let viewModel = ViewModel()
    
    // video player layer
    lazy var playLayer:AVPlayerLayer = {
        let playView = AVPlayerLayer()
        playView.contentsGravity = .resizeAspect
        playView.needsDisplayOnBoundsChange = true
        return playView
    }()
    
    
    // play button config
    lazy var playBtnConfig:UIButton.Configuration = {
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.image = UIImage(systemName: "play.fill")
        btnConfig.background.backgroundColor = .clear
        return btnConfig
    }()
    
    // play button
    lazy var playButton:UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        btn.configuration = playBtnConfig
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // next
    lazy var nextPlayButton:UIButton = {
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.image = UIImage(systemName: "forward.end.fill")
        btnConfig.background.backgroundColor = .clear
        let btn = UIButton()
        btn.configuration = btnConfig
        btn.alpha = 0.0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // previos
    lazy var previosPlayButton:UIButton = {
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.image = UIImage(systemName: "backward.end.fill")
        btnConfig.background.backgroundColor = .clear
        let btn = UIButton()
        btn.configuration = btnConfig
        btn.alpha = 0.0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var toolsBar:UIStackView = {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyView2 = UIView()
        emptyView2.translatesAutoresizingMaskIntoConstraints = false
         
        let stackCenterView = UIStackView(arrangedSubviews: [previosPlayButton,playButton ,nextPlayButton])
        stackCenterView.spacing = 10.0
        stackCenterView.axis = .horizontal
        stackCenterView.alignment = .fill
        stackCenterView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [emptyView,stackCenterView,emptyView2])
        stackView.spacing = 10.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
    }
     
    // hidden animate
    func onHiddenToolsbar(){
        self.toolsBar.alpha = 1.0
        UIView.animate(withDuration: 0.2 ,delay: 2.0 ,options: .curveEaseOut) {
            self.toolsBar.alpha = 0.0
        } completion: { isSuccess in
            self.toolsBar.alpha = 0.0
        }
    }
    
    func setupAudio(){
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failled.")
        }
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupController()
    }
    
    func setupController(){
        // setup playlayer
        viewModel.renderVideoPlayer(playerUrl: playUrlDefault) { player in
            
            self.playLayer.player = player
            self.playLayer.frame = self.contentView.bounds
            
            self.contentView.layer.addSublayer(self.playLayer)
        } onError: { error in
            debugPrint(error)
        }

        
        // setup tools bar
        contentView.addSubview(toolsBar)
        toolsBar.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        toolsBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        toolsBar.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        toolsBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self.toolsBar)
        if self.toolsBar.frame.contains(location) {
            // touch in the view
            
            if self.toolsBar.alpha == 0.0 {
                self.toolsBar.alpha = 1.0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @objc func didPauseVideo(sender:UIButton){
        playLayer.player?.pause()
        sender.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        sender.configuration?.image = UIImage(systemName: "play.fill")
        onHiddenToolsbar()
    }
     
    @objc func didPlayVideo(sender:UIButton){
        onPlayVideo()
    }
    
    func onPlayVideo(){
        playLayer.player?.play()
        self.playButton.addTarget(self, action: #selector(didPauseVideo), for: .touchUpInside)
        self.playButton.configuration?.image = UIImage(systemName: "pause.fill")
        onHiddenToolsbar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVideoItem" {
            let vc = segue.destination as! ViewTableViewController
            vc.viewTableViewControllerDelegate = self
        }
    }
    
}


extension ViewController: ViewTableViewControllerDelegate {
    
    func onLoadVideo(playerURL:[String]){
        dump( playerURL )
    }
    
    func selectedVideo(playerURL: String) {
        
        // reset player
        playLayer.player = nil
        playButton.removeTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        playButton.configuration?.showsActivityIndicator = true
        playButton.configuration?.background.image = UIImage()
        
        if toolsBar.alpha == 0.0 {
            toolsBar.alpha = 1.0
        }
        
        //setup new video player
        viewModel.renderVideoPlayer(playerUrl: playerURL) { player in
            self.playLayer.player = player
            self.onPlayVideo()
            
            DispatchQueue.main.async { [self] in
                playButton.configuration?.showsActivityIndicator = false
                playButton.configuration = playBtnConfig
                playButton.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
            }
            
        } onError: { error in
            debugPrint(error)
        }
         
        //self.playLayer.player = onLoadVideo(palyerUrl: playerURL)
        //onPlayVideo()
    }
}
 


extension AVPlayerViewController {
  
    // In App
    open override func viewWillAppear(_ animated: Bool) {
        print("\n== In AVPlayerViewController ==")
        print("== ViewWillAppear ==")
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        print("\n== In AVPlayerViewController ==")
        print("== viewDidAppear ==")
        self.player?.play()
    }
    
    // In background
    open override func viewWillDisappear(_ animated: Bool) {
        print("\n== In AVPlayerViewController ==")
        print("== ViewWillDisappear ==")
        
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        print("\n== In AVPlayerViewController ==")
        print("== ViewDidDisappear ==")
        self.player?.pause()
        
    }
     
}
