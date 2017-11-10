//
//  ViewController.swift
//  ReplayKitMovie
//
//  Created by Atsushi OMATA on 2017/11/09.
//  Copyright © 2017 Atsushi OMATA. All rights reserved.
//

import UIKit
import Material
import Font_Awesome_Swift

class ViewController: UITabBarController {
    let CAMERA_TAG = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        var viewControllers: [UIViewController] = []
        
        let cameraViewController = TabCameraViewController()
        cameraViewController.tabBarItem = UITabBarItem.init(title: "ビデオ撮影", image: UIImage.init(icon: FAType.FACamera, size: CGSize.init(width: 35, height: 35)), tag: CAMERA_TAG)
        viewControllers.append(cameraViewController)
        
        self.setViewControllers(viewControllers, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == CAMERA_TAG {
            print("camera ON")
            let cameraViewController = CameraViewController()
            self.present(cameraViewController, animated: true, completion: nil)
        }
    }
}

