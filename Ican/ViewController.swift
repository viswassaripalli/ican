//
//  ViewController.swift
//  Sesgoritma
//
//  Created by Arda Mavi on 21.03.2018.
//  Copyright © 2018 Sesgoritma. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation

@available(iOS 12.0, *)
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var but1: UIButton!
    @IBOutlet weak var but7: UIButton!
    @IBOutlet weak var but6: UIButton!
    @IBOutlet weak var but5: UIButton!
    @IBOutlet weak var but4: UIButton!
    @IBOutlet weak var but3: UIButton!
    @IBOutlet weak var but2: UIButton!
    
  
    var text:[String] = []
    @IBAction func clck1(_ sender: Any) {
        if(but1.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but1.titleLabel?.text == "nothing" || but1.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but1.titleLabel!.text!)
        }
        
    }
    
    @IBAction func clck2(_ sender: Any) {
        if(but2.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but2.titleLabel?.text == "nothing" || but2.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but2.titleLabel!.text!)
        }
        
    }
    
    
    @IBAction func clck3(_ sender: Any) {
        if(but3.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but3.titleLabel?.text == "nothing" || but3.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but3.titleLabel!.text!)
        }
        
    }
    
    
    @IBAction func clck4(_ sender: Any) {
        if(but4.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but4.titleLabel?.text == "nothing" || but4.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but4.titleLabel!.text!)
        }
        
    }
    
    @IBAction func clck5(_ sender: Any) {
        if(but5.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but5.titleLabel?.text == "nothing" || but5.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but5.titleLabel!.text!)
        }
        
    }
    
    @IBAction func clck6(_ sender: Any) {
        if(but6.titleLabel?.text=="space"){
            self.text.append(" ")
        }
        else if (but6.titleLabel?.text == "nothing" || but6.titleLabel?.text == "del")
        {
            ///
        }
        else
        {
            self.text.append(self.but6 .titleLabel!.text!)
        }
        
    }
    @IBAction func clck7(_ sender: Any) {
        if(text.count>=0){
        self.text.removeLast()
        }
    }
    var captureSession = AVCaptureSession()
    let synth = AVSpeechSynthesizer()
    var cameraPos = AVCaptureDevice.Position.front
    var captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.back)
    var def_bright = UIScreen.main.brightness // Default screen brightness
    var old_char = ""
    let model = try? VNCoreMLModel(for: Sign().model)
    
    @IBOutlet var predictLabel: UILabel!
    @IBAction func stop_captureSession(_ sender: UIButton) {
        captureSession.stopRunning()
       
        UIApplication.shared.isIdleTimerDisabled = false
        UIScreen.main.brightness = def_bright
    }
    
    
    
    @IBAction func change_camera(_ sender: Any) {
        captureSession.stopRunning()
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        if cameraPos == AVCaptureDevice.Position.back{
            cameraPos = AVCaptureDevice.Position.front
        }else{
            if UIScreen.main.brightness != def_bright{
                UIScreen.main.brightness = def_bright
            }
            cameraPos = AVCaptureDevice.Position.back
        }
        if lightSwitch.isOn{
            lightSwitch.setOn(false, animated: true)
        }
        captureSession = AVCaptureSession()
        view.layer.sublayers?[0].removeFromSuperlayer()
        old_char = ""
        self.viewDidLoad()
    }
    @IBOutlet var lightSwitch: UISwitch!
    @IBAction func change_light(_ sender: UISwitch) {
        if cameraPos == AVCaptureDevice.Position.back{
            try? captureDevice?.lockForConfiguration()
            if sender.isOn{
                try? captureDevice?.setTorchModeOn(level: 1.0)
            }else{
                captureDevice?.torchMode = .off
            }
            captureDevice?.unlockForConfiguration()
        }else{
            if sender.isOn{
                def_bright = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1)
            }else{
                UIScreen.main.brightness = def_bright
            }
        }
    }
     var arr:[String] = []
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.shared.isIdleTimerDisabled = true // Deactivate sleep mode
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        captureSession.sessionPreset = .photo
        
        self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPos)
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
            
            guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
           
            var j:Int = 0;
            for i in results{
                if(j==6){
                    break
                }
                else{
                    self.arr.append(i.identifier)
                   
                    j+=1
                    
                }
            
            }
            print(self.arr)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                // Put your code which should be executed with a delay here
             
                if(self.arr.count>6)
                {
                    self.but1.setTitle(self.arr[0], for: .normal)
                     self.but2.setTitle(self.arr[1], for: .normal)
                     self.but3.setTitle(self.arr[2], for: .normal)
                     self.but4.setTitle(self.arr[3], for: .normal)
                     self.but5.setTitle(self.arr[4], for: .normal)
                     self.but6.setTitle(self.arr[5], for: .normal)
                     self.but7.setTitle("del", for: .normal)
                    
                    
                
                }
                self.arr.removeAll()
              
          
                    // For secondary vocalization
                
                    self.predictLabel.text = self.text.joined(separator: "")
                    
               
            })
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

