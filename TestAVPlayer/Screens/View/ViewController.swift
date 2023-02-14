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

protocol ViewControllerDelegate:AnyObject {
    func selectedItem(selectedAt:Int)
}

class ViewController: CustomViewController ,AVPlayerViewControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    public weak var viewControllerDelegate: ViewControllerDelegate?
    
    var testPlayerUrl = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8"
    var totalTime = "00:00"
    var player: AVPlayer?
    var currentPlayVideo:Int = 0
    var playerURLs = [String]()
    let viewModel = ViewModel()
    var timeObserver: Any?
    var isMuted = false
    
    var progressBarHighlightedObserver: NSKeyValueObservation?
    
    
    
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
        btn.addTarget(self, action: #selector(didNextVideo), for: .touchUpInside)
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
        btn.addTarget(self, action: #selector(didPreviosVideo), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var muteButton:UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(didMuted), for: .touchUpInside)
        return btn
    }()
    
    lazy var slider:UISlider = {
        let slider = UISlider()
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        //slider.minimumTrackTintColor = .systemRed
        //slider.maximumTrackTintColor = .white
        slider.thumbTintColor = .systemRed
        slider.tintColor = .systemRed
        slider.backgroundColor = .clear
        slider.value = 0.0
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(didSliderChange), for: .valueChanged)
        
        //slider.addTarget(self, action: #selector(didSliderChange), for: .)
        
        // not working..
        progressBarHighlightedObserver = slider.observe(\UISlider.isTracking ,options: [.old,.new]) { slider, change in
            if let newValue = change.newValue {
                print("new value....")
            }
        }
         
        return slider
    }()
    
    /*
    lazy var toolsBar:UIStackView = {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyView2 = UIView()
        emptyView2.translatesAutoresizingMaskIntoConstraints = false
        emptyView2.backgroundColor = .systemRed
         
        // center stack view
        let centerStackView = UIStackView(arrangedSubviews: [previosPlayButton,playButton ,nextPlayButton])
        centerStackView.spacing = 10.0
        centerStackView.axis = .horizontal
        centerStackView.alignment = .fill
        centerStackView.distribution = .fillEqually
         
        // bottom stack view
        let bottomStackView = UIStackView(arrangedSubviews: [slider])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.backgroundColor = .clear
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fill
         
        // main stack view
        let mainStackView = UIStackView(arrangedSubviews: [emptyView,centerStackView,bottomStackView])
        mainStackView.spacing = 10.0
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.backgroundColor = .clear
        
        return mainStackView
    }()
    */
    
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: CGFloat(12.0))
        return label
    }()
    
    lazy var controllerStackView:UIStackView = {
        let mainStackView = UIStackView(arrangedSubviews: [previosPlayButton, playButton,nextPlayButton])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.distribution = .fill
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.spacing = CGFloat(20.0)
        mainStackView.backgroundColor = .clear
        
        return mainStackView
    }()
    
    lazy var bottomBarStackView:UIStackView = {
        
        timeLabel.text = "00:00 / 00:00"
        
        let emptyView = UIView()
        
        let topStackView = UIStackView(arrangedSubviews: [timeLabel,emptyView,muteButton])
        topStackView.axis = .horizontal
        
        let mainStackView = UIStackView(arrangedSubviews: [topStackView,slider])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = CGFloat(10)
        mainStackView.backgroundColor = .clear
         
        muteButton.widthAnchor.constraint(equalToConstant: CGFloat(50.0)).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: CGFloat(100.0)).isActive = true
        
        return mainStackView
    }()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
     
    // hidden animate
    func onHiddenToolsbar(){
        self.controllerStackView.alpha = CGFloat(1.0)
        UIView.animate(withDuration: 0.2 ,delay: 2.0 ,options: .curveEaseOut) {
            self.controllerStackView.alpha = CGFloat(0.0)
        } completion: { isSuccess in
            self.controllerStackView.alpha = CGFloat(0.0)
        }
    }
    
    func setupAudio(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failled.")
        }
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupController()
    }
    
    func setupController(){
         
        
        self.playLayer.frame = self.contentView.bounds
        self.contentView.layer.addSublayer(self.playLayer)
        
        // setup tools bar df
        contentView.addSubview(controllerStackView)
        controllerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        controllerStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        controllerStackView.heightAnchor.constraint(equalToConstant: CGFloat(80)).isActive = true
         
        // setup tools bar
        contentView.addSubview(bottomBarStackView)
        bottomBarStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: CGFloat(10.0)).isActive = true
        bottomBarStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CGFloat(10.0)).isActive = true
        bottomBarStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -CGFloat(10.0)).isActive = true
        bottomBarStackView.heightAnchor.constraint(equalToConstant: CGFloat(50.0)).isActive = true

    }
    
    var isTouched = false
    
    // touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self.contentView)
        if isTouched == false {
            if self.contentView.frame.contains(location) {
                self.controllerStackView.alpha = CGFloat(1.0)
                isTouched = true
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    self.controllerStackView.alpha = CGFloat(0.0)
                    self.isTouched = false
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func didSliderChange(sender:UISlider){
        print("== didSliderChange ==")
    }
    
    @objc func didMuted(sender:UIButton){
        if isMuted == false {
            sender.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
            isMuted = true
        } else {
            sender.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            isMuted = false
        }
        
        self.playLayer.player?.isMuted = isMuted
        
    }
     
    @objc func didPlayVideo(sender:UIButton){
        onPlayVideo()
    }
     
    @objc func didNextVideo(sender:UIButton){
        guard self.playerURLs.count > 0 else { return }
       
        if currentPlayVideo < self.playerURLs.count-1 {
            currentPlayVideo = currentPlayVideo + 1
            postObserver(name: .next ,userInfo: ["row":currentPlayVideo])
        }
    }
    
    @objc func didPreviosVideo(){
        guard self.playerURLs.count > 0 else { return }
        if currentPlayVideo > 0 {
            currentPlayVideo = currentPlayVideo - 1
            postObserver(name: .previos ,userInfo: ["row":currentPlayVideo])
        }
    }
    
    @objc func didPauseVideo(sender:UIButton){
        playLayer.player?.pause()
        sender.removeTarget(self, action: #selector(didPauseVideo), for: .touchUpInside)
        sender.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        //sender.configuration?.image = UIImage(systemName: "play.fill")
        sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func onPlayVideo(){
        self.playButton.removeTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(didPauseVideo), for: .touchUpInside)
        //self.playButton.configuration?.image = UIImage(systemName: "pause.fill")
        self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playLayer.player?.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVideoItem" {
            let vc = segue.destination as! ViewTableViewController
            vc.viewTableViewControllerDelegate = self
        }
    }
}


extension ViewController: ViewTableViewControllerDelegate {
    
    
    
    func onLoadPlayerItem(playerURLs:[String]){
        self.playerURLs = playerURLs
    }
    
    
    func selectedVideo(playerURL: String, indexPath: Int) {
         
        // reset player
        playLayer.player = nil
        
        // set play button
        playButton.removeTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        playButton.configuration?.showsActivityIndicator = true
        playButton.configuration?.background.image = UIImage()
        
        // setup next button
        nextPlayButton.alpha = 0.0
        
        // setup previos button
        previosPlayButton.alpha = 0.0
        
        // index item
        self.currentPlayVideo = indexPath
        
        //setup new video player
        viewModel.renderVideoPlayer(playerUrl: self.testPlayerUrl) { player in
            
            if player.status == .readyToPlay {
                
                self.playLayer.player = player
                 
                self.slider.minimumValue = 0.0
                self.slider.maximumValue = Float(CMTimeGetSeconds( (player.currentItem?.asset.duration)! ) )
                
                guard let totalCurrentTime = (player.currentItem?.asset.duration) else { return }
                let mins = CMTimeGetSeconds(totalCurrentTime) / 60
                let secs = CMTimeGetSeconds(totalCurrentTime).truncatingRemainder(dividingBy: 60)
                
                let timeformatter = NumberFormatter()
                    timeformatter.minimumIntegerDigits = 2
                    timeformatter.minimumFractionDigits = 0
                    timeformatter.roundingMode = .down
                guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                    return
                }
                self.totalTime = "\(minsStr):\(secsStr)"
                
                
                let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { time in
                    // update slider bar
                    self.updateslider(palyer: player)
                })
                 
                
                /*
                 // get current time
                 guard let currentTime = player?.currentTime() else { return }
                     let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
                 //
                 */
                
                DispatchQueue.main.async { [self] in
                    playButton.configuration?.showsActivityIndicator = false
                    playButton.configuration = playBtnConfig
                    playButton.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
                    
                    // setup next button
                    nextPlayButton.alpha = 1.0
                    
                    // setup previos button
                    previosPlayButton.alpha = 1.0
                    
                    self.onPlayVideo()
                    
                    //  sound off = (true)
                    // sound on = (false)
                    player.isMuted = isMuted
                    
                    self.onHiddenToolsbar()
                }
            }
            
        } onError: { error in
            debugPrint(error)
        }
        
    }
    
    func updateslider(palyer:AVPlayer?){
        guard let currentTime = (palyer?.currentItem?.currentTime()) else { return }
        
        let mins = CMTimeGetSeconds(currentTime) / 60
        let secs = CMTimeGetSeconds(currentTime).truncatingRemainder(dividingBy: 60)
        
        let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
        guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        
        // show the current time in the label.
        self.timeLabel.text = "\(minsStr):\(secsStr) / \(self.totalTime)"
        
        // input to the slider
        self.slider.value = Float(CMTimeGetSeconds(currentTime))
          
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
