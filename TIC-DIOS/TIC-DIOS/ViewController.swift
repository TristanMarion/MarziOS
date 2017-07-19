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
    let ennemy_image_name = "balcon.png"
    
    var ammo_id = 0
    var ennemy_id = 0
    
    var ammo_array: Array<UIImageView> = []
    var ennemy_array: Array<UIImageView> = []
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Without this line Marzi's position is reset at each new ammo
        self.marzi.translatesAutoresizingMaskIntoConstraints = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func ammoGenerator() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.createAmmo), userInfo: nil, repeats: true)
    }
    
    func ennemyGenerator() {
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.createEnnemy), userInfo: nil, repeats: true)
    }
    
    // Managing Marzi's movements
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            
            let marzi_semi_width = marzi.frame.width / 2
            let marzi_semi_height = marzi.frame.height / 2
            
            // Marzi is faster than your finger
            var pos_x = marzi.center.x + translation.x * 1
            var pos_y = marzi.center.y + translation.y * 1
            
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
            image_view.tag = 1000 + ammo_id
            
            ammo_id += 1
            ammo_array.append(image_view)
            
            image_view.center = CGPoint(x: marzi.center.x, y: marzi.center.y)
            image_view.startRotating()
            
            view.addSubview(image_view)
            animateAmmo(image_view)
        }
    }
    
    func animateAmmo(_ img: UIImageView) {
        UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.curveLinear,
            animations: {
            img.center.y = -100
        }, completion: { (true) in
            img.stopRotating()
            img.removeFromSuperview()
            self.ammo_array.removeFirst()
        })
    }
    
    func createEnnemy() {
        let ennemy_image = UIImage(named: ennemy_image_name)
        if (ennemy_image != nil && ennemy_image!.cgImage != nil) {
            let image_view = UIImageView(image: ennemy_image!)
            let ennemy_size = CGSize(width: ennemy_image!.cgImage!.width / 3, height: ennemy_image!.cgImage!.height / 3)
            
            let min_x = CGFloat(ennemy_image!.cgImage!.width / 3) / 2
            print(min_x)
            let max_x = view.frame.width - min_x
            let random_x = CGFloat(arc4random_uniform(UInt32(max_x - min_x))) + min_x
            
            image_view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ennemy_size)
            image_view.tag = 10000 + ennemy_id
            ennemy_id += 1
            ennemy_array.append(image_view)
            image_view.center = CGPoint(x: random_x, y: -100)
            view.addSubview(image_view)
            animateEnnemy(image_view)
        }
    }
    
    func animateEnnemy(_ img: UIImageView) {
        UIView.animate(withDuration: 5, delay: 0, options: UIViewAnimationOptions.curveLinear,
            animations: {
            img.center.y = self.view.frame.height + 200
        }, completion: { (true) in
            img.removeFromSuperview()
            self.ennemy_array.removeFirst()
        })
    }
}
