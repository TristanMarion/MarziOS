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
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.marzi.translatesAutoresizingMaskIntoConstraints = true
        scheduledTimerWithTimeInterval()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.createAmmo), userInfo: nil, repeats: true)
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
            let image_view = UIImageView(image: ammo_image!)
            let ammo_size = CGSize(width: ammo_image!.cgImage!.width / 10, height: ammo_image!.cgImage!.height / 10)
            image_view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ammo_size)
            image_view.tag = 1000 + ammo_number
            ammo_number += 1
            ammo_array.append(image_view)
            view.addSubview(image_view)
            image_view.center = CGPoint(x: marzi.center.x, y: marzi.center.y)
            image_view.startRotating()
            animateAmmo(image_view)
        }
    }
    
    func animateAmmo(_ img: UIImageView) {
        UIView.animate(withDuration: 2, animations: {
            img.center.y = -100
        }, completion: { (true) in
            img.stopRotating()
            self.ammo_array.removeFirst()
        })
    }
}
