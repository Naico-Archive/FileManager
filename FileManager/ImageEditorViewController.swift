//
//  ImageEditorViewController.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 24/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import TOCropViewController

class ImageEditorViewController: UIViewController, TOCropViewControllerDelegate {
    
    @IBOutlet weak var editImage: UIImageView!
    var cropViewController = TOCropViewController()
    
    @IBAction func btnEditImageTapped(sender: AnyObject) {
        let image = UIImage(named: "background images")
        self.cropViewController = TOCropViewController(image: image)
        self.cropViewController.delegate = self
        self.presentViewController(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        self.editImage.image = image
        self.cropViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnCloseTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
