//
//  MainViewController.swift
//  ShenSuan
//
//  Created by yangying on 2021/6/22.
//

import Foundation
import UIKit
import Masonry
import Alamofire

class MainViewController : UIViewController, ImagePickerDelegate {
    var topImage = UIImageView()
    var captureButton = UIButton()
    var albumButton = UIButton()
    var imagePicker: ImagePicker!
    var imageViewController : ImageViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        imageViewController = ImageViewController()
        
        self.view.backgroundColor = UIColor.white
        
        topImage.image = UIImage.init(named: "main_top_image")
        self.view.addSubview(topImage)
        topImage.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view)?.setOffset(200)
            make?.centerX.equalTo()(self.view)
            make?.height.equalTo()(200)
            make?.width.equalTo()(200)
        }
        
        captureButton.setTitle("拍照", for: UIControl.State.normal)
        captureButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 1
        captureButton.layer.cornerRadius = 5
        self.view.addSubview(captureButton)
        captureButton.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.topImage.mas_bottom)?.setOffset(50)
            make?.centerX.equalTo()(self.view.mas_centerX)?.setOffset(-70)
            make?.height.equalTo()(50)
            make?.width.equalTo()(100)
        }
        captureButton.addTarget(self, action: #selector(didSelectCaptureButton), for: UIControl.Event.touchUpInside)
        
        albumButton.setTitle("相册上传", for: UIControl.State.normal)
        albumButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        albumButton.layer.borderColor = UIColor.black.cgColor
        albumButton.layer.borderWidth = 1
        albumButton.layer.cornerRadius = 5
        self.view.addSubview(albumButton)
        albumButton.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.topImage.mas_bottom)?.setOffset(50)
            make?.centerX.equalTo()(self.view.mas_centerX)?.setOffset(70)
            make?.height.equalTo()(50)
            make?.width.equalTo()(100)
        }
        albumButton.addTarget(self, action: #selector(didSelectAlbumButton), for: UIControl.Event.touchUpInside)
    }
    
    @objc func didSelectAlbumButton() {
        imagePicker.fetchPhotoFromAlbum()
    }
    
    @objc func didSelectCaptureButton() {
        imagePicker.fetchPhotoFromCamera()
    }
    
    // ImagePickerDelegate
    func didSelect(image: UIImage?) {
        imageViewController.photoImage = image ?? UIImage()
        self.navigationController?.pushViewController(imageViewController, animated: true)
//        self.uploadImage(uploadImage: image)
    }
    
    func uploadImage(uploadImage: UIImage?) {
        guard let image = uploadImage else {
            return
        }
        let data = image.jpegData(compressionQuality: 0.5)

        let DocumentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let filePath = DocumentsPath.path?.appending("/image.png")
        let fileManager = FileManager.default

        try! fileManager.createDirectory(atPath: DocumentsPath.path!, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFile(atPath: filePath!, contents: data, attributes: nil)
        
        AF.upload(multipartFormData: { multipartFormData in
            let lastData = NSData(contentsOfFile: filePath!)
            multipartFormData.append(lastData! as Data, withName: "image")
        }, to: "http://10.2.248.227:8001", method: .post).responseData { (response) in
            print(response)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
