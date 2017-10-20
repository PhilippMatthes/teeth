//
//  ViewController.swift
//  teeth
//
//  Created by Philipp Matthes on 20.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var transparancyView: UIImageView!
    @IBOutlet weak var locator: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconOffset: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var mouthBackground: UIView!
    @IBOutlet weak var barBackground: UIImageView!
    var progressBar: ProgressBar!
    let gradientLayer = CAGradientLayer()
    var isRunning = false
    weak var timer: Timer?
    var count = 180
//
//    let audioEngine = AVAudioEngine()
//    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
//    let request = SFSpeechAudioBufferRecognitionRequest()
//    var recognitionTask: SFSpeechRecognitionTask?
    
    var currentBackgroundColors = [CGColor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.layoutIfNeeded()
        setUpLayout()
        setUpBackground(with: view.frame, on: view)
        setUpProgressBar(with: view.frame, on: barBackground)
//        recordAndRecognizeSpeech()
        
        let buttonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.buttonClicked(sender:)))
        buttonBackground.addGestureRecognizer(buttonRecognizer)
    }
    
    @objc func buttonClicked(sender:UITapGestureRecognizer) {
        if isRunning {
            stop()
        }
        else {
            start()
        }
        animateButtonPressOn(background: buttonBackground)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animateButtonReleaseOff(background: self.buttonBackground)
        })
    }
        
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLayout() {
        print(NSLocalizedString("bereit", comment: "bereit"))
        locator.text = NSLocalizedString("bereit", comment: "bereit")
        iconOffset.constant = 2.0
        buttonBackground.layer.cornerRadius = 50
        mouthBackground.layer.backgroundColor = Constants.backgroundColor0.cgColor
        timeLabel.textColor = Constants.backgroundColor0
        transparancyView.layer.zPosition = 1;
    }
    
    func animateButtonPressOn(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = 4.0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 0.0
        background.layer.borderColor = UIColor.black.cgColor as CGColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 4.0
    }
    
    func animateButtonReleaseOff(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 4.0
        borderWidth.toValue = 0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 4.0
        background.layer.borderColor = UIColor.black.cgColor as CGColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 0.0
    }
    
    func setUpProgressBar(with frame: CGRect, on view: UIView) {
        progressBar = ProgressBar(frame: frame)
        progressBar.drawBar(with: view.frame, on: view)
        progressBar.animateBar(duration: 5,
                               currentValue: 90,
                               maxValue: 90)
        self.view.addSubview(barBackground)
    }
    
    func setUpBackground(with frame: CGRect, on view: UIView) {
        gradientLayer.frame = frame
        currentBackgroundColors = [Constants.backgroundColor1.cgColor as CGColor,
                                   Constants.backgroundColor1.cgColor as CGColor]
        gradientLayer.colors = currentBackgroundColors
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func start() {
        isRunning = true
        refreshButton(running: true)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDownOneSecond), userInfo: nil, repeats: true)
    }
    
    func stop() {
        isRunning = false
        refreshButton(running: false)
        timer?.invalidate()
    }
    
    func refreshButton(running: Bool) {
        if running {
            iconOffset.constant = 0.0
            icon.image = UIImage(named:"StopIcon")
        }
        else {
            iconOffset.constant = 2.0
            icon.image = UIImage(named:"PlayIcon")
        }
    }
    
    @objc func countDownOneSecond() {
        count -= 1
        let seconds = count % 60
        let minutes = Int(count / 60)
        var secondsString = String(seconds)
        if seconds < 10 {
            secondsString = "0"+String(seconds)
        }
        timeLabel.text = String(minutes)+":"+String(secondsString)
        let upCount = 0 - (count-180)
        if count <= 0 {
            stop()
            count = 180
            timeLabel.text = "3:00"
            progressBar.switchImage(to: UIImage(named: "UpperJaw")!, withBackground: UIImage(named: "UpperJawShadow")!, on: self.barBackground, and: transparancyView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.progressBar.animateBar(duration: 2.0, currentValue: 90, maxValue: 90)
                })
            locator.text = NSLocalizedString("bereit", comment: "bereit")
        }
        if upCount == 90 {
            progressBar.switchImage(to: UIImage(named: "LowerJaw")!, withBackground: UIImage(named: "LowerJawShadow")!, on: self.barBackground, and: transparancyView)
            locator.text = NSLocalizedString("unten", comment: "unten")
        }
        if upCount < 90 {
            locator.text = NSLocalizedString("oben", comment: "oben")
        }
        progressBar.animateBar(duration: 1, currentValue: CGFloat(upCount%90), maxValue: 90)
    }
    
//    func recordAndRecognizeSpeech() {
//        let node = audioEngine.inputNode
//        let recordingFormat = node.outputFormat(forBus: 0)
//        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {buffer, _ in self.request.append(buffer)}
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//        } catch {
//            return print(error)
//        }
//        guard let myRecognizer = SFSpeechRecognizer() else {
//            return
//        }
//        if !myRecognizer.isAvailable {
//            return
//        }
//        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
//            if let result = result {
//                let bestString = result.bestTranscription.formattedString
//                var lastString: String = ""
//                for segment in result.bestTranscription.segments {
//                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
//                    lastString = String(bestString[indexTo...])
//                }
//                if lastString == "start" {
//                    if !self.isRunning {
//                        print("start")
//                        self.start()
//                    }
//                }
//                if lastString == "stop" {
//                    if self.isRunning {
//                        self.stop()
//                    }
//                }
//            }
//            else if let error = error {
//                print(error)
//            }
//        })
//    }


}

