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

class customSlider:UISlider {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
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
    var isFullscreen = false
     
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
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
    
    lazy var playbackSlider:UISlider = {
        let slider = UISlider()
         
        slider.translatesAutoresizingMaskIntoConstraints = false
        //slider.minimumTrackTintColor = .systemRed
        //slider.maximumTrackTintColor = .white
        slider.thumbTintColor = .systemRed
        slider.tintColor = .systemRed
        slider.backgroundColor = .clear
        slider.value = 0.0
        slider.isContinuous = false
          
        progressBarHighlightedObserver = slider.observe(\UISlider.isTracking ,options: [.old,.new]) { slider, change in
            if let newValue = change.newValue {
                self.updateSlider(isTracking: newValue)
            }
        }
        return slider
    }()
     
    
    lazy var fullscreenButton:UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(didFullscree), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: CGFloat(12.0))
        label.text = "00:00 / 00:00" //default
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
     
    lazy var topStackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullscreenButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var bottomBarStackView:UIStackView = {
        let emptyView = UIView()
        
        let topStackView = UIStackView(arrangedSubviews: [timeLabel,emptyView,muteButton])
        topStackView.axis = .horizontal
        
        let mainStackView = UIStackView(arrangedSubviews: [topStackView,playbackSlider])
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
        self.playbackSlider.thumbTintColor = .systemRed
        self.fullscreenButton.alpha = 1.0
        self.muteButton.alpha = 1.0
        UIView.animate(withDuration: 0.2 ,delay: 2.0 ,options: .curveEaseOut) {
            self.controllerStackView.alpha = CGFloat(0.0)
            self.fullscreenButton.alpha = 0.0
            self.playbackSlider.thumbTintColor = .clear
            self.muteButton.alpha = 0.0
        } completion: { isSuccess in
            self.controllerStackView.alpha = CGFloat(0.0)
            self.fullscreenButton.alpha = 0.0
            self.playbackSlider.thumbTintColor = .clear
            self.playbackSlider.isEnabled = false
            self.muteButton.alpha = 0.0
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
         
        contentView.addSubview(topStackView)
        topStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(10)).isActive = true
        topStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -CGFloat(10)).isActive = true
        topStackView.heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        
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
                // contorller stack view
                self.controllerStackView.alpha = CGFloat(1.0)
                // playback slider
                self.playbackSlider.thumbTintColor = .systemRed
                self.playbackSlider.isEnabled = true
                // mute button
                self.muteButton.alpha = 1.0
                // fullscreen button
                self.fullscreenButton.alpha = 1.0
                
                isTouched = true
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    // controller stack view
                    self.controllerStackView.alpha = CGFloat(0.0)
                    // playback slider
                    self.playbackSlider.thumbTintColor = .clear
                    self.playbackSlider.isEnabled = false
                    // mute button
                    self.muteButton.alpha = 0.0
                    // fullscreen button
                    self.fullscreenButton.alpha = 0.0
                    
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.playLayer.videoGravity = .resizeAspect
        self.playLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.view.layoutIfNeeded()
         
    }
    
    @objc func didFullscree(sender:UIButton){
       
        if isFullscreen == false {
            if #available(iOS 16.0, *) {
                (UIApplication.shared.delegate as? AppDelegate)?.orientation = .landscapeRight
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                setNeedsUpdateOfSupportedInterfaceOrientations()
            }else{
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
            
            sender.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
            isFullscreen = true

            let screen = UIScreen.main.bounds
            self.view.bringSubviewToFront(self.contentView)
            contentViewLeftConstraint.constant = CGFloat(0)
            contentViewTopConstraint.constant = CGFloat(0)
            contentViewRightConstraint.constant = CGFloat(0)
            contentViewHeightConstraint.constant = CGFloat(screen.height - 120)
            self.view.backgroundColor = .black
            self.view.layoutIfNeeded()

        } else {
            isFullscreen = false
            self.contentView.bringSubviewToFront(self.view)
            contentViewLeftConstraint.constant = CGFloat(10.0)
            contentViewTopConstraint.constant = CGFloat(10.0)
            contentViewRightConstraint.constant = CGFloat(10.0)
            contentViewHeightConstraint.constant = CGFloat(300.0)

            self.view.backgroundColor = .white
            self.view.layoutIfNeeded()

            self.playLayer.frame = self.contentView.bounds
            self.view.layoutIfNeeded()
        }
        
        
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
    
    private func onResetPlayerControl(){
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
        
        // setup playback slider
        playbackSlider.alpha = 0.0
        
        // setup fullscreen button
        fullscreenButton.alpha = 0.0
        
        // setup mute button
        muteButton.alpha = 0.0
    }
    
    private func onSetPlayerControl(){
        playButton.configuration?.showsActivityIndicator = false
        playButton.configuration = playBtnConfig
        playButton.addTarget(self, action: #selector(didPlayVideo), for: .touchUpInside)
        
        // setup next button
        nextPlayButton.alpha = 1.0
        
        // setup previos button
        previosPlayButton.alpha = 1.0
        
        // setup playback slider
        playbackSlider.alpha = 1.0
        
        // setup fullscreen button
        fullscreenButton.alpha = 1.0
        
        // setup mute button
        muteButton.alpha = 1.0
        
        onPlayVideo()
        
        // sound off = (true)
        // sound on = (false)
        //player.isMuted = isMuted
        
        
        
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
     
    func onLoadPlayerItem(playerURLs:[String]){
        self.playerURLs = playerURLs
    }
    
    func selectedVideo(playerURL: String, indexPath: Int) {
         
        self.onResetPlayerControl()
         
         
        // index item
        self.currentPlayVideo = indexPath
        dump( playerURL )
        //setup new video player
        viewModel.renderVideoPlayer(playerUrl: playerURL) { player in
        //viewModel.renderVideoPlayer(playerUrl: self.testPlayerUrl) { player in
            
            if player.status == .readyToPlay {
                
                self.playLayer.player = player
                
                //self.playLayer.contentsGravity
                 
                self.playbackSlider.minimumValue = 0.0
                self.playbackSlider.maximumValue = Float(CMTimeGetSeconds( (player.currentItem?.asset.duration)! ) )
                
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
                    self.updateSlider(isTracking: false)
                })
                  
                DispatchQueue.main.async { [self] in
                    onSetPlayerControl()
                }
            }
            
        } onError: { error in
            debugPrint(error)
        }
         
    }
    
    func updateSlider(isTracking:Bool){
        
        if isTracking {
            // pause
            //self.playLayer.player?.pause()
            
            // get value
            let timeSeconds = self.playbackSlider.value // get current value
            let timescale = 1 // for 1 seconds.
            
            // cover to CMTime
            let seekTime = CMTimeMakeWithSeconds(Float64(timeSeconds), preferredTimescale: Int32(timescale))
             
            let getCurrentTime = viewModel.renderCurrentTimeframe(currentTime: seekTime)
            
            // show the current time in the label.
            self.timeLabel.text = "\(getCurrentTime) / \(self.totalTime)"
            
            self.playLayer.player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { isFinished in
                if isFinished {
                    self.playLayer.player?.play()
                }
            })
        } else {
            
            guard let currentTime = (self.playLayer.player?.currentItem?.currentTime()) else { return }
            
            let getCurrentTime = viewModel.renderCurrentTimeframe(currentTime: currentTime)
              
            // show the current time in the label.
            self.timeLabel.text = "\(getCurrentTime) / \(self.totalTime)"
            
            // input to the slider
            self.playbackSlider.value = Float(CMTimeGetSeconds(currentTime))
        }
         
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
