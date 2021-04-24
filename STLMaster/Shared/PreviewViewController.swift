//
//  PreviewViewController.swift
//  Rendering-ios
//
//  Created by Dinesh Manni on 23/04/21.
//  Copyright © 2021 Metal By Example. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    var snapshot = UIImage.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func OnToolItemClick(_ sender: UIBarButtonItem) {
        
        switch sender.tag {
        case 100:
            self.dismiss(animated: true, completion: nil)
            break
        case 101:
            do
            {
                let imageToShare = [ snapshot ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                   activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

                   // exclude some activity types from the list (optional)
                   //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]

                   // present the view controller
                   self.present(activityViewController, animated: true, completion: nil)
            }
            break
        case 102:
            UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
            self.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
    }
    func SetImage(image : UIImage) {
        
        snapshot = image
        let imageView = self.view.viewWithTag(100) as! UIImageView
      //  let imageView = self.view as! UIImageView
        imageView.image = image
        
    }
}
