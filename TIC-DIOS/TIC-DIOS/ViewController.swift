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
            
            let marzi_semi_width = marzi.frame.width / 2
            let marzi_semi_height = marzi.frame.height / 2
            
            // Marzi is faster than your finger
            var pos_x = marzi.center.x + translation.x * 1.5
            var pos_y = marzi.center.y + translation.y * 1.5
            
            // if Marzi is not at a good x value
            pos_x = pos_x < marzi_semi_width ? marzi_semi_width : pos_x
            pos_x = pos_x > view.frame.width - marzi_semi_width ? view.frame.width - marzi_semi_width : pos_x
            
            // if Marzi is not at a good y value
            pos_y = pos_y < marzi_semi_height ? marzi_semi_height : pos_y
            pos_y = pos_y > view.frame.height - marzi_semi_height ? view.frame.height - marzi_semi_height : pos_y
            
            marzi.center = CGPoint(x: pos_x, y: pos_y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
}

