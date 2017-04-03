//
//  VoiceView.swift
//  Lily
//
//  Created by Tom Reinhart on 3/30/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Speech
import SwiftSiriWaveformView

@IBDesignable
class VoiceView: UIView, SFSpeechRecognizerDelegate {

    @IBOutlet var view: UIView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var tapToSpeakLabel: UILabel!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var audioView: SwiftSiriWaveformView!

    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    // Siri Wave Vars
    var timer:Timer?
    var change:CGFloat = 0.01

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    @IBAction func micButtonPressed(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.audioView.isHidden = true
            self.tapToSpeakLabel.text = "Tap to speak"
            self.micButton.setImage(UIImage(named: "MicWhite"), for: .normal)
            self.micButton.isEnabled = true
            
        } else {
            print("starting recording")
            startRecording()
            self.tapToSpeakLabel.isHidden = false
            self.audioView.isHidden = false
            self.micButton.setImage(UIImage(named: "micWithOrangeBorder"), for: .normal)
            self.tapToSpeakLabel.text = "Tap to stop recording"
            self.micButton.isEnabled = true
            
        }
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func helpButtonPressed(_ sender: Any) {
        print("Help pressed")
    }
    func setupView() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "VoiceView", bundle: bundle).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        self.loadMicrophoneAtLaunch()
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = false
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                isFinal = (result?.isFinal)!
                var query = result?.bestTranscription.formattedString
                query = query?.replacingOccurrences(of: "Cagle's", with: "kegels")
                query = query?.replacingOccurrences(of: "Cagle", with: "kegel")
                
                SweetAlert().showAlert("Is this OK?", subTitle: "\(query ?? "Oops. Something went wrong.")", style: AlertStyle.warning, buttonTitle:"Nope!", buttonColor:Helpers.UIColorFromRGB(rgbValue: 0xD0D0D0) , otherButtonTitle:  "YES!", otherButtonColor: Helpers.UIColorFromRGB(rgbValue: 0xDD6B55)) { (isOtherButton) -> Void in
                    if isOtherButton == true {
                        
                         _ = SweetAlert().showAlert("Cancelled!", subTitle: "Let's give this another try", style: AlertStyle.error) // left
                    }
                    else {
                        _ = SweetAlert().showAlert("Awesome!", subTitle: "Doing what you asked!", style: AlertStyle.success)
                    }
                }
                
                
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.enableMics()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
                self.tapToSpeakLabel.isHidden = false
                self.tapToSpeakLabel.text = "Say something, I'm listening!"
        
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.enableMics()
        } else {
            self.disableMics()
        }
    }

    
    internal func refreshAudioView(_:Timer) {
                if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
                    self.change *= -1.0
                }
        
                // Simply set the amplitude to whatever you need and the view will update itself.
                self.audioView.amplitude += self.change
    }
    
    func loadMicrophoneAtLaunch() {
        timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(refreshAudioView(_:)), userInfo: nil, repeats: true)
        
        self.disableMics()
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                //                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                //                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                //                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                if isButtonEnabled {
                    self.enableMics()
                } else {
                    self.disableMics()
                }
            }
        }
    }
    func disableMics() {
        print("disable mic")
        //self.view.rightBarButtonItem?.isEnabled = false
        //        self.tapToSpeakButton.isEnabled = false
    }
    func enableMics() {
        print("enable mic")
        //self.navigationItem.rightBarButtonItem?.isEnabled = true
        //        self.tapToSpeakButton.isEnabled = true
        
    }
    
}

