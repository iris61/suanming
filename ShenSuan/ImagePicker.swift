//
//  ImagePicker.swift
//  AIFortunetelling
//  选择图片or拍照
//  Created by bytedance on 2021/6/18.
//

import UIKit
import Photos

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

final class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
        
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true, completion: nil)
        }
    }
    
    public func fetchPhotoFromAlbum() {
        PHPhotoLibrary.requestAuthorization({ [weak self] status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self?.showImagePicker(from: .photoLibrary)
                }
            default:
                self?.showNoAccesionAlertAndCancel(type: .photoLibrary)
            }
        })
    }
    
    public func fetchPhotoFromCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] enable in
            if enable {
                DispatchQueue.main.async {
                    self?.showImagePicker(from: .camera)
                }
            } else {
                self?.showNoAccesionAlertAndCancel(type: .camera)
            }
        }
    }
    
    private func showNoAccesionAlertAndCancel(type: UIImagePickerController.SourceType) {
        guard type != .savedPhotosAlbum else {
            return
        }
        
        let sourceType = type == .camera ? "相机" : "相册"
        let alert = UIAlertController(title: "未获得\(sourceType)授权", message: "前往系统设置开启权限", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          return
        }))
        
        self.presentationController?.present(alert, animated: true, completion: nil)
    }
    
    private func showImagePicker(from sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return
        }
        
        self.pickerController.sourceType = sourceType
        
        self.presentationController?.present(self.pickerController, animated: true, completion: nil)
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("image picker did selected")
        delegate?.didSelect(image: info[.editedImage] as? UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image picker did cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}
