//
//  CameraViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/8/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import ImageIO
import QuartzCore

protocol CameraPhotoDelegate {
    
    func cameraPictureSelected(data: NSData!) -> Void
    
}

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraView : UIView!
    
    var stillImageOutput = AVCaptureStillImageOutput()
    
    var delegate : CameraPhotoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "takePhoto")
        self.navigationItem.rightBarButtonItem = camera
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Create Capture Session
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        //Setup Preview Layer
        var layer = self.cameraView.layer
        var previewLayer = AVCaptureVideoPreviewLayer(layer: layer)
        previewLayer.frame = self.cameraView.frame
        self.cameraView.layer.addSublayer(previewLayer)
        
        //Setup Input Device
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        
        if error != nil {
            captureSession.addInput(input)
            
            //Create Output
            var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            self.stillImageOutput.outputSettings = outputSettings
            captureSession.addOutput(self.stillImageOutput)
            
            captureSession.startRunning()
        }
        
    }
    
    func takePhoto() {
        var videoConnection : AVCaptureConnection?
        
        for connection in self.stillImageOutput.connections {
            
            //If there is a connection, create cameraConnection variable as AVCaptureConnection
            if let cameraConnection = connection as? AVCaptureConnection {
                
                for port in cameraConnection.inputPorts {
                    
                    //If there is a port, create videoPort as an AVCaptureInputPort
                    if let videoPort = port as? AVCaptureInputPort {
                        
                        //If videoPort is equal to AVMediaTypeVideo, set videoConnection above to cameraConnection in stillImageOutput connections
                        if videoPort.mediaType == AVMediaTypeVideo {
                            
                            videoConnection = cameraConnection
                        }
                    }
                }
            }
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
            
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            self.delegate!.cameraPictureSelected(data)
            
        })
        
    }

    
}
