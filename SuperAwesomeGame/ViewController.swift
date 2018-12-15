//
//  ViewController.swift
//  SuperAwesomeGame
//
//  Created by Brenden Vogt on 12/14/18.
//  Copyright © 2018 BrendenVogt. All rights reserved.
//

import UIKit

class Vector {
    var x : CGFloat = 0
    var y : CGFloat = 0
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var character: UIImageView!
    @IBOutlet var characterBaseX: NSLayoutConstraint!
    @IBOutlet var characterBaseY: NSLayoutConstraint!
    
    
    var velocityX: CGFloat = 10.0
    var velocityY: CGFloat = 0.0
    
    var gravity: CGFloat = 1.5
    var deceleration: CGFloat = 0.96
    
    var minY: CGFloat = 25.0
    
    var dPadDeadZone: CGFloat = 20.0
    
    @IBOutlet var aButton: UIImageView!
    @IBOutlet var bButton: UIImageView!
    @IBOutlet var dPad: UIImageView!
    
    var dPadLocation: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    public func addGesture(view: UIView, action: Selector?, delegate: UIGestureRecognizerDelegate) {
        let gest = UILongPressGestureRecognizer(target: self, action: action)
        gest.delegate = delegate
        gest.minimumPressDuration = 0
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gest)
    }
    
    func start(){
        addGesture(view: aButton, action: #selector(ViewController.aTapped(_:)), delegate: self)
        addGesture(view: bButton, action: #selector(ViewController.bTapped(_:)), delegate: self)
        addGesture(view: dPad, action: #selector(ViewController.dPadTouched(_:)), delegate: self)
        
        Timer.scheduledTimer(timeInterval: 0.0166666, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    
    @objc func update() {
        
        if let dPadLocation = dPadLocation {
            calcMove(dPadLocation)
        }
        
        //Y
        var newY = characterBaseY.constant
        velocityY = velocityY - gravity
        newY = max(newY + velocityY, minY)
        if (newY <= minY) {
            velocityY = 0
        }
        characterBaseY.constant = newY
        
        //X
        var newX = characterBaseX.constant
        
        //
        if newX > view.frame.size.width {
            newX = -50
        }else if newX < -50 {
            newX = view.frame.size.width
        }
        
        //
        newX = newX + velocityX
        if (newY <= minY) {
            if (abs(velocityX) > 0) {
                velocityX = velocityX * deceleration
            }
        }
        
        characterBaseX.constant = newX
    }
    
    func jump(){
        velocityY = 20
    }
    
    func moveLeft(){
        print("moveLeft")
        velocityX = max(velocityX - 1, -15)
    }
    
    func moveRight(){
        print("moveRight")
        velocityX = min(velocityX + 1, 15)
    }
    
    func moveUp(){
        print("moveUp")
    }
    
    func moveDown(){
        print("moveDown")
    }
    
    func calcMove(_ location : CGPoint){
        if (location.x < self.dPad.frame.size.width/2 - dPadDeadZone){
            moveLeft()
        }else if (location.x > self.dPad.frame.size.width/2 + dPadDeadZone){
            moveRight()
        }
        if (location.y < self.dPad.frame.size.height/2 - dPadDeadZone){
            moveUp()
        }else if (location.y > self.dPad.frame.size.height/2 + dPadDeadZone){
            moveDown()
        }
    }
    
    @objc func bTapped(_ rec:UITapGestureRecognizer) {
        if (rec.state == .began){
            print("btapped")
        }
    }
    
    @objc func aTapped(_ rec:UITapGestureRecognizer) {
        if (rec.state == .began){
            print("atapped")
            jump()
        }
    }
    
    @objc func dPadTouched(_ rec:UITapGestureRecognizer) {
        dPadLocation = rec.location(in: dPad)
        if (rec.state == .ended) {
            dPadLocation = nil
        }
    }

}

