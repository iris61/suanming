//
//  ImageViewController.swift
//  ShenSuan
//
//  Created by yangying on 2021/6/22.
//

import Foundation
import UIKit

class ImageViewController : UIViewController {
    var photoView = UIImageView()
    var photoImage : UIImage? {
        didSet {
            self.photoView.image = photoImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(photoView)
        
        photoView.contentMode = .scaleAspectFit
        photoView.mas_makeConstraints { (make) in
            make?.width.equalTo()(self.view)
            make?.height.equalTo()(self.view)
        }
    }
}
