//
//  CustomImageView.swift
//  FileManager
//
//  Created by Vineeth Vijayan on 24/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit

@IBDesignable class CustomImageView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    var view: UIView!
    
    @IBAction func btnImageButtonTapped(sender: AnyObject) {
////        print(self.parentViewController?.restorationIdentifier)
//        let imageEditorViewController = ImageEditorViewController()
////        parentViewController?.popoverPresentationController = 
//        parentViewController?.presentViewController(imageEditorViewController, animated: true, completion: nil)

        let vc = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("ImageEditorViewController") as! ImageEditorViewController
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = UIModalPresentationStyle.PageSheet
        let popover = nav.popoverPresentationController
//        popover?.delegate = self.parentViewController
//        vc.preferredContentSize = CGSizeMake(450,600)
        
        self.parentViewController!.presentViewController(nav, animated: true, completion: nil)

    }
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CustomImageView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    @IBInspectable internal var BackgroundImage: UIImage = UIImage() {
        didSet {
            self.imageView.image = BackgroundImage
        }
    }

}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
