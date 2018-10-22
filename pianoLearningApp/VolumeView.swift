//
//  VolumeView.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/16.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class VolumeView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var volumeLeftImage: UIImageView!
    @IBOutlet weak var volumeRightImage: UIImageView!
    @IBOutlet weak var volumeBMGImage: UIImageView!
    @IBOutlet weak var volumeTempoImage: UIImageView!
    @IBOutlet weak var volumeLeftLabel: UILabel!
    @IBOutlet weak var volumeRightLabel: UILabel!
    @IBOutlet weak var volumeBMGLabel: UILabel!
    @IBOutlet weak var volumeTempoLabel: UILabel!
    @IBOutlet weak var volumeLeftSlider: CustomvVolumeSlider!
    @IBOutlet weak var volumeRightSlider: CustomvVolumeSlider!
    @IBOutlet weak var volumeBMGSlider: CustomvVolumeSlider!
    @IBOutlet weak var volumeTempoSlider: CustomvVolumeSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView() {
        volumeLeftSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        volumeRightSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        volumeBMGSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        volumeTempoSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        volumeLeftLabel.text = "\(Int(volumeLeftSlider.value))%"
        volumeRightLabel.text = "\(Int(volumeRightSlider.value))%"
        volumeBMGLabel.text = "\(Int(volumeBMGSlider.value))%"
        volumeTempoLabel.text = "\(Int(volumeTempoSlider.value))%"
        if volumeLeftSlider.value == 0 {
            volumeLeftImage.image = UIImage(named: "accoutns_volume_l_0")
        }
        if volumeRightSlider.value == 0 {
            volumeRightImage.image = UIImage(named: "accoutns_volume_r_0")
        }
        if volumeBMGSlider.value == 0 {
            volumeBMGImage.image = UIImage(named: "accoutns_volume_bmg_0")
        }
        if volumeTempoSlider.value == 0 {
            volumeTempoImage.image = UIImage(named: "accoutns_volume_tempo_0")
        }
    }
    
    @IBAction func SlidVolumeLeft(_ sender: UISlider) {
        volumeLeftLabel.text = "\(Int(sender.value))%"
        if sender.value == 0 {
            volumeLeftImage.image = UIImage(named: "accoutns_volume_l_0")
        }else {
            volumeLeftImage.image = UIImage(named: "accoutns_volume_l")
        }
    }
    
    @IBAction func SlidVolumeRight(_ sender: UISlider) {
        volumeRightLabel.text = "\(Int(sender.value))%"
        if sender.value == 0 {
            volumeRightImage.image = UIImage(named: "accoutns_volume_r_0")
        }else {
            volumeRightImage.image = UIImage(named: "accoutns_volume_r")
        }
    }
    
    @IBAction func SlidVolumeBMG(_ sender: UISlider) {
        volumeBMGLabel.text = "\(Int(sender.value))%"
        if sender.value == 0 {
            volumeBMGImage.image = UIImage(named: "accoutns_volume_bgm_0")
        }else {
            volumeBMGImage.image = UIImage(named: "accoutns_volume_bgm")
        }
    }
    
    @IBAction func SlidVolumeTempo(_ sender: UISlider) {
        volumeTempoLabel.text = "\(Int(sender.value))%"
        if sender.value == 0 {
            volumeTempoImage.image = UIImage(named: "accoutns_volume_tempo_0")
        }else {
            volumeTempoImage.image = UIImage(named: "accoutns_volume_tempo")
        }
    }
    
}
