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
    
    let ammo_image_name = "chaise"
    var ammo_number = 0
    var ammo_array: Array<UIImageView> = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func createAmmo() {
        let ammo_image = UIImage(named: ammo_image_name)
        if (ammo_image != nil && ammo_image!.cgImage != nil) {
            let imageView = UIImageView(image: ammo_image!)
            let ammo_size = CGSize(width: ammo_image!.cgImage!.width / 10, height: ammo_image!.cgImage!.height / 10)
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ammo_size)
            imageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            imageView.tag = 1000 + ammo_number
            ammo_number += 1
            ammo_array.append(imageView)
            view.addSubview(imageView)
            imageView.center = CGPoint(x: marzi.center.x, y: marzi.center.y)
            print(ammo_array)
        }
    }
}
