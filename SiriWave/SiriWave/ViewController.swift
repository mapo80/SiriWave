//
//  ViewController.swift
//  SiriWave
//
//  Created by politom on 08/03/2019.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var siriWave: SiriWaveView!
    
    private var recorder:AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecorder()
    }
    
    private func testWithoutMic() {
        var ampl: CGFloat = 1
        var speed: CGFloat = 0.2

        func modulate() {
            ampl = Lerp.lerp(ampl, 1.5, 0.1)
            //speed = Lerp.lerp(speed, 1, 0.1)
            self.siriWave.update(ampl * 1.5)
        }
        
        _ = Timeout.setInterval(0.2) {
            DispatchQueue.main.async {
                modulate()
            }
        }
    }
    
    //Recorder Setup Begin
    @objc
    func setupRecorder() {
        if(checkMicPermission()) {
            startRecording()
        } else {
            print("permission denied")
        }
    }
    
    @objc
    func updateMeters() {
        var normalizedValue: Float
        recorder.updateMeters()
        normalizedValue = normalizedPowerLevelFromDecibels(decibels: recorder.averagePower(forChannel: 0))
        
//        print("normalizedValue: \(normalizedValue)")
        
        self.siriWave.update(CGFloat(normalizedValue) * 10)
    }
    
    private func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        let recorderSettings = [AVSampleRateKey: NSNumber(value:44100.0),
                                AVFormatIDKey: NSNumber(value:kAudioFormatAppleLossless),
                                AVNumberOfChannelsKey: NSNumber(value: 2),
                                AVEncoderAudioQualityKey: NSNumber(value: Int8(AVAudioQuality.min.rawValue))]
        
        let url:URL = URL(fileURLWithPath:"/dev/null");
        do {
            
            let displayLink: CADisplayLink = CADisplayLink(target: self,
                                                           selector: #selector(ViewController.updateMeters))
            displayLink.add(to: RunLoop.current,
                            forMode: RunLoop.Mode.common)

            try recordingSession.setCategory(.playAndRecord,
                                             mode: .default)
            try recordingSession.setActive(true)
            self.recorder = try AVAudioRecorder.init(url: url,
                                                     settings: recorderSettings as [String : Any])
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true;
            self.recorder.record()
            print("recorder enabled")
        } catch {
            print("recorder init failed")
        }
    }
    
    private func checkMicPermission() -> Bool {
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = true
        case AVAudioSession.RecordPermission.denied:
            permissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        
        return permissionCheck
    }
    private func normalizedPowerLevelFromDecibels(decibels:Float) -> Float {
        if (decibels < -60.0 || decibels == 0.0) {
            return 0.0;
        }
        
        return pow((pow(10.0, 0.05 * decibels) - pow(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - pow(10.0, 0.05 * -60.0))), 1.0 / 2.0);
        
    }
}

