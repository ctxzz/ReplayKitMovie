//
//  CameraViewController.swift
//  ReplayKitMovie
//
//  Created by Atsushi OMATA on 2017/11/10.
//  Copyright © 2017 Atsushi OMATA. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Material

class CameraViewController: UIViewController {
    var recordButton: FABButton!
    var cancelButton: UIButton!
    var timeLabel: UILabel!
    var isRecordingLabel: UILabel!
    var timer: Timer!

    var session: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    
    var timeRecord = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        self.title = "ビデオ撮影"
        buildSession()
        
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: session)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
        
        let previewLayerConnection = videoLayer.connection
        if (previewLayerConnection?.isVideoOrientationSupported)! {
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 80, height: 50))
        timeLabel.center.x = view.center.x
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.textColor = UIColor.white
        timeLabel.text = "00:00"
        timeLabel.textAlignment = NSTextAlignment.center
        timeLabel.font = UIFont.systemFont(ofSize: CGFloat(20))
        view.addSubview(timeLabel)
        
        isRecordingLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 80, height: 50))
        isRecordingLabel.center.x = view.center.x - 80
        isRecordingLabel.backgroundColor = UIColor.clear
        isRecordingLabel.textColor = UIColor.red
        isRecordingLabel.text = "録画中"
        isRecordingLabel.textAlignment = NSTextAlignment.center
        isRecordingLabel.font = UIFont.systemFont(ofSize: CGFloat(20))
        view.addSubview(isRecordingLabel)
        isRecordingLabel.isHidden = true
        
        recordButton = FABButton(image: Icon.cm.videocam, tintColor: UIColor.white)
        recordButton.frame = CGRect(x: self.view.bounds.width - 80, y: 0, width: 50, height: 50)
        recordButton.center.y = view.center.y
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.layer.borderWidth = 3
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("", for: UIControlState.normal)
        recordButton.addTarget(self, action: #selector(self.onRecordButton(_:)), for: .touchUpInside)
        view.addSubview(recordButton)
        
        cancelButton = UIButton(frame: CGRect(x: self.view.bounds.width - 80, y: self.view.bounds.height - 80, width: 50, height: 50))
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 25
        cancelButton.layer.masksToBounds = true
        cancelButton.setTitle("戻る", for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(self.onCancelButton(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func buildSession() {
        let videoCaptureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let audioCaputurDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone, for: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified)
        
        session = AVCaptureSession()
        if session.canSetSessionPreset(AVCaptureSession.Preset.vga640x480) {
            session.sessionPreset = AVCaptureSession.Preset.vga640x480
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            let audioInput = try AVCaptureDeviceInput(device: audioCaputurDevice!)
            if session.canAddInput(videoInput) && session.canAddInput(audioInput) {
                session.addInput(videoInput)
                session.addInput(audioInput)
            }
        } catch let error as NSError {
            print("Cannot use device. \(error)")
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
    }
    
    @objc func onRecordButton(_ sender: UIButton) {
        if !videoOutput.isRecording {
            self.cancelButton.isHidden = true
            self.isRecordingLabel.isHidden = false
            self.recordButton.image = Icon.cm.close
            
            let labelAnimation = CABasicAnimation.init(keyPath: "opacity")
            labelAnimation.duration = 1.0
            labelAnimation.toValue = 0.0
            labelAnimation.fromValue = 1.0
            labelAnimation.repeatCount = Float.infinity
            self.isRecordingLabel.layer.add(labelAnimation, forKey: nil)
            
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentDirectory = paths[0]
            let fileName = UUID().uuidString + ".mov"
            let filePath = "\(documentDirectory)/\(fileName)"
            let fileURL = URL.init(fileURLWithPath: filePath)
            videoOutput.startRecording(to: fileURL, recordingDelegate: self)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(recordTimeUpdate), userInfo: nil, repeats: true)
        } else {
            self.recordButton.image = Icon.cm.videocam
            videoOutput.stopRecording()
        }
    }
    
    @objc func onCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func recordTimeUpdate() {
        timeRecord += 1
        let minute = timeRecord / 60
        let second = timeRecord - minute * 60
        let secondString = String.init(format: "%02d", second)
        let minuteString = String.init(format: "%02d", minute)
        timeLabel.text = "\(minuteString):\(secondString)"
    }

}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.timer.invalidate()
            self.timeRecord = 0
            self.timeLabel.text = "00:00"
            self.cancelButton.isHidden = false
            self.isRecordingLabel.isHidden = true
        }
    }
}

