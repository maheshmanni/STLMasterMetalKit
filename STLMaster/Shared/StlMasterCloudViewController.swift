//
//  StlMasterCloudViewController.swift
//  Rendering
//
//  Created by Dinesh Manni on 22/04/21.
//  Copyright © 2021 Metal By Example. All rights reserved.
//

import UIKit

class StlMasterCloudViewController: UIDocumentBrowserViewController, UIDocumentPickerDelegate, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        //self.se
        // Do any additional setup after loading the view.
    }
    

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
