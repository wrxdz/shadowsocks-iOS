//
//  TestPictureInPictureViewController.swift
//  FuncTest-swift
//
//  Created by admin on 2022/11/26.
//  Copyright © 2022 Wrxdz. All rights reserved.
//

import Foundation
import AVKit
import Social

var _testPipVC: TestPictureInPictureViewController?


class TestPictureInPictureViewController: UIViewController {
    
    private lazy var pipView: FuncPipView = {
        let view = FuncPipView()
        return view
    }()
    
    private lazy var pipContentView: FuncPipContentView = {
        let view = FuncPipContentView()
        return view
    }()
    
    private lazy var pipStartView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var isUseGCDWebServer = true
    
    fileprivate var pipVC: AVPictureInPictureController?
    private var stopPipComplete: (() -> ())?
    private weak var pgWindow: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "测试画中画功能"
        initView()
        setupPipVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //pipView.player?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //stopPictureInPicture(nil)
    }
    
    private func initView() {
        view.backgroundColor = .white
        pipView.testPipVC = self
        pipStartView.addGestureRecognizer((UITapGestureRecognizer(target: self, action: #selector(pipStartTapAction))))
        
        
        view.addSubview(pipView)
        view.addSubview(pipStartView)
        
        // 第二种样式
//        pipView.snp.makeConstraints { make in
//            make.width.equalTo(180)
//            make.height.equalTo(400)
//            make.center.equalToSuperview()
//        }
        
//        pipStartView.snp.makeConstraints { make in
//            UITool.topSafeEqualSuper(view, topLayoutGuide, offset: 30, make)
//            make.centerX.equalToSuperview()
//            make.width.height.equalTo(44)
//        }
        pipView.translatesAutoresizingMaskIntoConstraints = false
        pipStartView.translatesAutoresizingMaskIntoConstraints = false
        
        pipView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        pipView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        pipView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pipView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        pipStartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        pipStartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pipStartView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
    }

    private func setupPipVC() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            Log.d(funcTag, msg: "不支持画中画!!!")
            return
        }
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("AVAudioSession发生错误")
        }
        
        if AVPictureInPictureController.isPictureInPictureSupported() {
            var startImage: UIImage
            if #available(iOS 13.0, *) {
                startImage = AVPictureInPictureController.pictureInPictureButtonStartImage
            } else {
                startImage =  AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil)
            }
            pipStartView.image = startImage
        }
        
        pipVC = AVPictureInPictureController.init(playerLayer: pipView.playerLayer)
        pipVC?.delegate = self
        pipVC?.setValue(1, forKey: "controlsStyle")
        
        pipContentView.pipVC = pipVC
    }
    
    @objc private func pipStartTapAction() {
        guard let pipVC = pipVC else { return }
        
        if pipVC.isPictureInPictureActive {
            pipVC.stopPictureInPicture()
        } else {
            if let playerVC = _testPipVC {
                playerVC.stopPictureInPicture {
                    pipVC.startPictureInPicture()
                }
            } else {
                pipVC.startPictureInPicture()
            }
        }
    }
    
    deinit {
        stopPictureInPicture(nil)
        pipContentView.stopClipTimer()
        pipContentView.stopGcdWebServerActive()
        //BackgroundTaskManager.shared.stopPlayAudioSession()
        pipContentView.removeFromSuperview()
    }
}

//MARK: -
extension TestPictureInPictureViewController: AVPictureInPictureControllerDelegate, UIGestureRecognizerDelegate {
    
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Log.d(funcTag, msg: "call willStartPip")
        
        let window = UIApplication.shared.windows.first
        window?.addSubview(pipContentView)
        pipContentView.startClipTimer()
        if isUseGCDWebServer { pipContentView.startGcdWebServerActiveTimer() }
        //BackgroundTaskManager.shared.startPlayAudioSession()
        if let window = window {
            pipContentView.translatesAutoresizingMaskIntoConstraints = false
            pipContentView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            pipContentView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            pipContentView.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
            pipContentView.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
        }
        //pipContentView.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Log.d(funcTag, msg: "call didStartPip")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        Log.d(funcTag, msg: "call failedToStartError=\(error)")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Log.d(funcTag, msg: "call willStopPip")
        pipContentView.stopClipTimer()
        pipContentView.stopGcdWebServerActive()
        //BackgroundTaskManager.shared.stopPlayAudioSession()
        pipContentView.removeFromSuperview()
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Log.d(funcTag, msg: "call didStopPip")
    }
    
    
    /**
     @method        pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
     @param        pictureInPictureController
     The Picture in Picture controller.
     @param        completionHandler
     The completion handler the delegate needs to call after restore.
     @abstract    Delegate can implement this method to restore the user interface before Picture in Picture stops.
     */
    
    /** 可以在画中画停止之前恢复用户页面 */
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        Log.d(funcTag, msg: "call restoreUserInterfacePip")
        
        completionHandler(true)
    }
    
    
    func stopPictureInPicture(_ complete: (()->())?) {
        if let pipVC = pipVC, pipVC.isPictureInPictureActive {
            stopPipComplete = complete
            pipVC.stopPictureInPicture()
        } else {
            stopPipComplete = nil
        }
    }
    
}

//MARK: - 自定义画中画的contentView
fileprivate class FuncPipContentView: BaseView, UIGestureRecognizerDelegate {
    
    weak var pipVC: AVPictureInPictureController?
    
    lazy var button: UIView = {
        let view = UIView()
        view.backgroundColor = .red.withAlphaComponent(0.4)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.text = "这是一段文本"
        view.font = .systemFont(ofSize: 14)
        view.textColor = .white
        return view
    }()
    
    private lazy var icon: UIImageView = {
        return UIImageView(image: UIImage(named: "flash"))
    }()
    
    private var scale: CGFloat = 1
    
    private var startClipTimerEnable = false
    private var clipTimer: Timer?
    private var lastClipCount: Int?
    
    private var gcdWebBackgroundTask: UIBackgroundTaskIdentifier?
    private var gcdWebServerActiveTimer: Timer?
    
    override func initView() {
        backgroundColor = .blue.withAlphaComponent(0.4)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        addSubview(button)
        addSubview(icon)
        addSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        button.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        
    }
    
    @objc private func tapAction() {
        guard let pipVC = pipVC else { return }
        
        //好像也不行
        //openGWD()
        
    }
    
    func startGcdWebServerActiveTimer() {
        stopGcdWebServerActive()
        
        gcdWebServerActiveTimer = Timer.scheduledTimer(timeInterval: TimeInterval(20), target: self, selector: #selector(self.gcdWebServerActive), userInfo: nil, repeats: true)
        gcdWebServerActive()
    }
    
    func stopGcdWebServerActive() {
        gcdWebServerActiveTimer?.invalidate()
        gcdWebServerActiveTimer = nil
    }
    
    func startClipTimer() {
        guard startClipTimerEnable else { return }
        stopClipTimer()
        
        self.clipTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.clipTimerAction), userInfo: nil, repeats: true)
    }
    
    func stopClipTimer() {
        clipTimer?.invalidate()
        clipTimer = nil
    }
    
    @objc private func clipTimerAction() {
        Log.d(funcTag, msg: "每隔一秒尝试扫描剪切板内容，changeCount=\(UIPasteboard.general.changeCount)")
        
        // 此效果和悬浮窗弹窗app中比价完全一致效果，轮询监听changCount变化，如果是链接内容，才访问剪切板内容，也保证不泛滥弹出隐私弹窗提示
        if lastClipCount == nil { lastClipCount = UIPasteboard.general.changeCount }
        if let lastCount = lastClipCount, UIPasteboard.general.changeCount > lastCount {
            let text = UIPasteboard.general.string ?? ""
//            if RegexHelper("http[s]?").match(text) {
//                LabelTipView.showTip(self, title: "检查url=\(text)", time: 2)
//                Log.d(funcTag, msg: "内容是url=\(text)")
//            }
            self.lastClipCount = UIPasteboard.general.changeCount
        }
        
        // 直接重新写入剪切板内容，可以保证无限次读取时不会二次弹出隐私提示弹窗(但粘贴时提示是从自己的app向其他app粘贴，这个无法避免的)
//        let text = UIPasteboard.general.string ?? ""
//        if text.starts(with: "https://") || text.starts(with: "http://") {
//            Log.d(funcTag, msg: "复制内容是http链接")
//        }
//        UIPasteboard.general.string = text
        
    }
    
    @objc private func clipBoardChanged(notification: Notification) {
        Log.d(funcTag, msg: "\(UIPasteboard.general.string ?? "")")
    }
    
    @objc private func gcdWebServerActive() {
        Log.d(funcTag, msg: "每隔20秒，激活次后台任务，保证gcdwebserver后台持久运行")
        if let task = gcdWebBackgroundTask {
            UIApplication.shared.endBackgroundTask(task)
            gcdWebBackgroundTask = nil
        }
        gcdWebBackgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let `self` = self else { return }
            if let gcdWebBackgroundTask = self.gcdWebBackgroundTask {
                UIApplication.shared.endBackgroundTask(gcdWebBackgroundTask)
            }
        }
    }
    
    private func shareGWD() {
        let composeVC = SLComposeServiceViewController()
        
    }
}

//MARK: - 自定义PlayerView
fileprivate class FuncPipView: BaseView {
    
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resize
        return layer
    }()
    
    var urlAsset: AVURLAsset?
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    weak var testPipVC: TestPictureInPictureViewController?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    override func initView() {
        backgroundColor = .blue.withAlphaComponent(0.4)
        layer.addSublayer(playerLayer)
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: videoPath()))
        urlAsset = asset
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = true
        player?.allowsExternalPlayback = true
        if let player = player {
            playerLayer.player = player
        }
        
    }
    
    private func videoPath() -> String {
        // 窗口形状由视频分辨率控制
        return Bundle.main.path(forResource: "holder2", ofType: "mp4")!
    }
    
}
