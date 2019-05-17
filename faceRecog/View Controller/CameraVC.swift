//
//  CameraVC.swift
//  FaceLogin
//
//  Created by William Huang on 9/14/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import ProjectOxfordFace



enum PhotoType {
    case login
    case signup
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var button: UIButton!
    
    var actIdc:UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var photoType: PhotoType!
    var userStorageRef: StorageReference!
    var personImage: UIImage!
    
    var faceFromPhoto: MPOFace!
    var faceFromFireBase: MPOFace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storageRef = Storage.storage().reference()
        userStorageRef = storageRef.child("users")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera, AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        for devise in (deviceSession.devices) {
            if devise.position == AVCaptureDevice.Position.front {
                do {
                    let input = try AVCaptureDeviceInput(device: devise)
                    
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                        
                        if captureSession.canAddOutput(sessionOutput) {
                            captureSession.addOutput(sessionOutput)
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            previewLayer.connection?.videoOrientation = .portrait
                            
                            cameraView.layer.addSublayer(previewLayer)
                            cameraView.addSubview(button)
                            
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2 )
                            
                            previewLayer.bounds = cameraView.frame
                            
                            captureSession.startRunning()
                        }
                    }
                    
                }catch let avError{
                    print(avError)
                }
            }
        }
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = photoSampleBuffer, let dataImg = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let userId = Auth.auth().currentUser?.uid
            let imageRef = userStorageRef.child("\(userId!).jpg")
            
            self.showActivityIndicator(onView: self.view)
            
            if photoType == PhotoType.signup {
                //upload to database
                self.personImage = UIImage(data: dataImg)
                
                let client = MPOFaceServiceClient(endpointAndSubscriptionKey: "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/", key: "4eedd9a2fcdf422d86ce74a5c0587c84")!
                
                let data = UIImageJPEGRepresentation(self.personImage!, 0.8)
                print(self.personImage)
                client.detect(with: data!, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if (faces!.count) > 1 || faces!.count == 0 {
                        print("Too many or not at all faces")
                        self.failLogin()
                        //self.actIdc.stopAnimating()
                        return
                    }
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    let uploadTask = imageRef.putData(dataImg, metadata: metaData, completion: {(metadata,error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                    
                    print("uploaded")
                    uploadTask.resume()
                   
                })
                
                self.captureSession.stopRunning()
                self.previewLayer.removeFromSuperlayer()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoggedIn")
                self.present(vc, animated: true, completion: nil)
                self.actIdc.stopAnimating()
               
            }else if photoType == PhotoType.login {
                //verify user
                self.personImage = UIImage(data: dataImg)
                captureSession.stopRunning()
                
                imageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    self.verify(withUrl: url!.absoluteString)
                    
                })
                
            }
            
        }
    }
    
    func verify(withUrl url: String) {
        
        let client = MPOFaceServiceClient(endpointAndSubscriptionKey: "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/", key: "4eedd9a2fcdf422d86ce74a5c0587c84")!
        
        
        let data = UIImageJPEGRepresentation(self.personImage!, 0.8)
        
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
            if error != nil{
                print(error!)
                return
            }
            
            if (faces?.count)! > 1 || faces!.count == 0 {
                print("Too many or not at all faces")
                self.failLogin()
                self.actIdc.stopAnimating()
                return
            }
            self.faceFromPhoto = faces![0]
            
            client.detect(withUrl: url, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                if error != nil {
                    print(error!)
                    return
                }
                self.faceFromFireBase = faces![0]
                
                client.verify(withFirstFaceId: self.faceFromPhoto.faceId, faceId2: self.faceFromFireBase.faceId, completionBlock: { (result, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if result!.isIdentical {
                        //THE person is same
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoggedIn")
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        self.failLogin()
                        self.actIdc.stopAnimating()
                    }
                })
            })
        })
    }
    
    func showActivityIndicator(onView:UIView){
        let container: UIView = UIView()
        container.frame = onView.frame
        container.center = onView.center
        container.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = onView.center
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actIdc = UIActivityIndicatorView()
        actIdc.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actIdc.hidesWhenStopped = true
        actIdc.activityIndicatorViewStyle = .whiteLarge
        actIdc.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(actIdc)
        container.addSubview(loadingView)
        onView.addSubview(container)
        
        actIdc.startAnimating()
    }
    
    func failLogin(){
        let alert = UIAlertController(title: "Failed login", message: "Face undetected", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let logVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
            self.present(logVC, animated: true, completion: nil)
        })
        
        alert.addAction(action)
        do {
            try Auth.auth().signOut()
        }catch{
            
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String : 160]
        
        settings.previewPhotoFormat = previewFormat
        sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
}


