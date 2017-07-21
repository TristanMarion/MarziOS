//
//  ViewController.swift
//  TIC-DIOS
//
//  Created by etna on 18/07/2017.
//  Copyright © 2017 etna. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var marzi: UIImageView!
    @IBOutlet weak var difficulty_picker: UIPickerView!
    @IBOutlet weak var select_button: UIButton!
    @IBOutlet weak var points_label: UILabel!
    
    var audio_player: AVAudioPlayer?
    var throw_player: AVAudioPlayer?
    var explosion_player: AVAudioPlayer?
    let music_game = NSDataAsset(name: "music_game")
    let music_menu = NSDataAsset(name: "music_menu")
    let sound_throw = NSDataAsset(name: "sound_throw")
    let sound_explosion = NSDataAsset(name: "sound_explosion")
    
    let difficulties = ["Easy", "Hard", "Hardcore"]
    let difficulties_value: Array<Array<Double>> = [
        [0.5, 5, 5],
        [1, 4, 4],
        [0.5, 1, 2]
    ]
    
    let ammo_image_name = "chaise"
    let ennemy_image_name = "balcon.png"
    let bonus_image_array = ["bonus_speed", "bonus_slow", "bonus_reverse"]
    let bonus_values: Array<Double> = [2, 0.5, -1]
    let bonus_duration: Array<Double> = [10, 5, 5]
    
    var ammo_id = 0
    var ennemy_id = 0
    var bonus_id = 0
    
    var ammo_array: Array<UIImageView> = []
    var ennemy_array: Array<UIImageView> = []
    var bonus_array: Array<(UIImageView, Double, Double)> = []
    
    var difficulty: Array<Double> = []
    var move_coeff = CGFloat(1.0)
    
    var collision_timer = Timer()
    var ammo_timer = Timer()
    var ennemy_timer = Timer()
    var bonus_timer = Timer()
    
    var points = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.difficulty_picker.dataSource = self
        self.difficulty_picker.delegate = self
        
        difficulty = self.difficulties_value[0]
        
        // Without this line Marzi's position is reset at each new ammo
        self.marzi.translatesAutoresizingMaskIntoConstraints = true
        marzi.isHidden = true
        
        playMenuMusic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return difficulties.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return difficulties[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        difficulty = difficulties_value[row]
    }
    
    @IBAction func selectDifficulty(_ sender: UIButton) {
        play()
    }
    
    func play() {
        updatePoints(-points)
        toggleUI()
        difficulty_picker.isHidden = true
        select_button.isHidden = true
        marzi.center = CGPoint(x: view.center.x, y: view.frame.height - 25 - marzi.frame.height / 2)
        marzi.isHidden = false
        ennemyGenerator()
        ammoGenerator()
        bonusGenerator()
        checkCollisions()
        playGameMusic()
    }
    
    func toggleUI() {
        marzi.isHidden = !marzi.isHidden
        difficulty_picker.isHidden = !difficulty_picker.isHidden
        select_button.isHidden = !select_button.isHidden
    }
    
    func ammoGenerator() {
        ammo_timer = Timer.scheduledTimer(timeInterval: difficulty[0], target: self, selector: #selector(self.createAmmo), userInfo: nil, repeats: true)
    }
    
    func ennemyGenerator() {
        ennemy_timer = Timer.scheduledTimer(timeInterval: TimeInterval(difficulty[1]), target: self, selector: #selector(self.createEnnemy), userInfo: nil, repeats: true)
    }
    
    func bonusGenerator() {
        bonus_timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.createBonus), userInfo: nil, repeats: true)
    }
    
    // Managing Marzi's movements
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            
            let marzi_semi_width = marzi.frame.width / 2
            let marzi_semi_height = marzi.frame.height / 2
            
            // Marzi is faster than your finger
            var pos_x = marzi.center.x + translation.x * move_coeff
            var pos_y = marzi.center.y + translation.y * move_coeff
            
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
    
    func checkCollisions() {
        var result = 0
        ennemy_array.forEach { (ennemy) in
            if (ennemy.layer.presentation() != nil &&  marzi.layer.presentation() != nil && ennemy.layer.presentation()!.frame.intersects(marzi.layer.presentation()!.frame)) {
                ennemy.removeFromSuperview()
                result = 1
            } else {
                ammo_array.forEach({ (ammo) in
                    if (ammo.layer.presentation() != nil && ennemy.layer.presentation() != nil && ammo.layer.presentation()!.frame.intersects(ennemy.layer.presentation()!.frame)) {
                        ennemy.removeFromSuperview()
                        playExplosionSound()
                        updatePoints(1)
                    }
                })
            }
        }
        bonus_array.forEach { (bonus) in
            if (bonus.0.layer.presentation() != nil && marzi.layer.presentation() != nil && bonus.0.layer.presentation()!.frame.intersects(marzi.layer.presentation()!.frame)) {
                bonus.0.removeFromSuperview()
                bonus_array.removeFirst()
                move_coeff = CGFloat(bonus.1)
                DispatchQueue.main.asyncAfter(deadline: .now() + bonus.2, execute: {
                    self.move_coeff = 1
                })
            }
        }
        if (result != 0) {
            endTimers()
            clearArrays()
            toggleUI()
            playMenuMusic()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.checkCollisions()
            })
        }
    }
    
    func endTimers() {
        collision_timer.invalidate()
        ammo_timer.invalidate()
        ennemy_timer.invalidate()
    }
    
    func clearArrays() {
        ennemy_array.forEach({ (ennemy) in
            ennemy.removeFromSuperview()
            ennemy.layer.removeAllAnimations()
        })
        ammo_array.forEach({ (ammo) in
            ammo.removeFromSuperview()
            ammo.layer.removeAllAnimations()
        })
        ennemy_array.removeAll()
        ammo_array.removeAll()
    }

    func updatePoints(_ added_points: Int) {
        points += added_points
        points_label.text = String(points)
    }
    
    func createAmmo() {
        let ammo_image = UIImage(named: ammo_image_name)
        if (ammo_image != nil && ammo_image!.cgImage != nil) {
            let image_view = UIImageView(image: ammo_image!)
            let ammo_size = CGSize(width: ammo_image!.cgImage!.width / 15, height: ammo_image!.cgImage!.height / 15)
            
            image_view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ammo_size)
            image_view.tag = 1000 + ammo_id
            
            ammo_id += 1
            ammo_array.append(image_view)
            
            image_view.center = CGPoint(x: marzi.center.x, y: marzi.center.y)
            image_view.startRotating()
            
            view.addSubview(image_view)
            playThrowSound()
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
            if (self.ammo_array.count > 0) {
                self.ammo_array.removeFirst()
            }
        })
    }
    
    func createEnnemy() {
        let ennemy_image = UIImage(named: ennemy_image_name)
        if (ennemy_image != nil && ennemy_image!.cgImage != nil) {
            let image_view = UIImageView(image: ennemy_image!)
            let ennemy_size = CGSize(width: ennemy_image!.cgImage!.width / 3, height: ennemy_image!.cgImage!.height / 3)
            
            let min_x = CGFloat(ennemy_image!.cgImage!.width / 3) / 2
            let max_x = view.frame.width - min_x
            let random_x = CGFloat(arc4random_uniform(UInt32(max_x - min_x))) + min_x
            
            image_view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: ennemy_size)
            image_view.tag = 10000 + ennemy_id
            ennemy_id += 1
            ennemy_array.append(image_view)
            image_view.center = CGPoint(x: random_x, y: -30)
            view.addSubview(image_view)
            animateEnnemy(image_view)
        }
    }
    
    func animateEnnemy(_ img: UIImageView) {
        UIView.animate(withDuration: TimeInterval(difficulty[2]), delay: 0, options: UIViewAnimationOptions.curveLinear,
            animations: {
            img.center.y = self.view.frame.height + img.frame.height
        }, completion: { (true) in
            img.removeFromSuperview()
            if (self.ennemy_array.count > 0) {
                self.ennemy_array.removeFirst()
            }
        })
    }
    
    func createBonus() {
        let rand = arc4random_uniform(3)
        let bonus_image = UIImage(named: bonus_image_array[Int(rand)])
        if (bonus_image != nil && bonus_image!.cgImage != nil) {
            let image_view = UIImageView(image: bonus_image!)
            let bonus_size = CGSize(width: bonus_image!.cgImage!.width, height: bonus_image!.cgImage!.height)
            
            let min_x = CGFloat(bonus_image!.cgImage!.width / 3) / 2
            let max_x = view.frame.width - min_x
            let random_x = CGFloat(arc4random_uniform(UInt32(max_x - min_x))) + min_x
            
            image_view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: bonus_size)
            image_view.tag = 100000 + bonus_id
            bonus_id += 1
            bonus_array.append((image_view, bonus_values[Int(rand)], bonus_duration[Int(rand)]))
            image_view.center = CGPoint(x: random_x, y: -image_view.frame.height)
            view.addSubview(image_view)
            animateBonus(image_view)
        }
    }
    
    func animateBonus(_ img: UIImageView) {
        UIView.animate(withDuration: TimeInterval(10), delay: 0, options: UIViewAnimationOptions.curveLinear,
                       animations: {
                        img.center.y = self.view.frame.height + img.frame.height
        }, completion: { (true) in
            img.removeFromSuperview()
            if (self.ennemy_array.count > 0) {
                self.ennemy_array.removeFirst()
            }
        })
    }
    
    func playMenuMusic() {
        if music_menu != nil {
            do {
                audio_player = try AVAudioPlayer(data: music_menu!.data, fileTypeHint: "aiff")
                audio_player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func playGameMusic() {
        if music_game != nil {
            do {
                audio_player = try AVAudioPlayer(data: music_game!.data, fileTypeHint: "aiff")
                audio_player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func playThrowSound() {
        if sound_throw != nil {
            do {
                throw_player = try AVAudioPlayer(data: sound_throw!.data, fileTypeHint: "aiff")
                throw_player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func playExplosionSound() {
        if sound_explosion != nil {
            do {
                explosion_player = try AVAudioPlayer(data: sound_explosion!.data, fileTypeHint: "aiff")
                explosion_player?.play()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
