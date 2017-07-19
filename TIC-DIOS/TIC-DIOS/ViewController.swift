//
//  ViewController.swift
//  TIC-DIOS
//
//  Created by etna on 18/07/2017.
//  Copyright © 2017 etna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var marzi: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            marzi.center = CGPoint(x: marzi.center.x + translation.x * 1.5, y: marzi.center.y + translation.y * 1.5)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
}

