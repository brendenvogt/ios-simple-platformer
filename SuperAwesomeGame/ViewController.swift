//
//  ViewController.swift
//  SuperAwesomeGame
//
//  Created by Brenden Vogt on 12/14/18.
//  Copyright © 2018 BrendenVogt. All rights reserved.
//

import UIKit

class Vector {
    init(_ x : CGFloat, _ y : CGFloat) {
        self.x = x
        self.y = y
    }
    var x : CGFloat = 0
    var y : CGFloat = 0
    
    static var zero = Vector(0, 0)
    
    static func +(left: Vector, right: Vector) -> Vector {
        return Vector(left.x + right.x, left.y + right.y)
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var character: UIImageView!
    @IBOutlet var characterBaseX: NSLayoutConstraint!
    @IBOutlet var characterBaseY: NSLayoutConstraint!

    var position : Vector = Vector(0, 100)
    var velocity : Vector = Vector(0, 0)
    var acceleration : Vector = Vector(0, 0)
    var gravity : Vector = Vector(0, -0.75)
    var floorForce : Vector = Vector(0, 0)
    
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
    
        position = position + velocity
        velocity = velocity + acceleration
        acceleration = gravity + floorForce
    
        if (position.y <= 25){
            floorForce = Vector(0, -gravity.y)
            velocity.y = 0
            position.y = 25
            print("collided with floor ")
        }else{
            floorForce = Vector.zero
            print("not collided")
        }
    
        if (position.x > view.frame.width) {
            position.x = -character.frame.width
        }else if (position.x < -character.frame.width){
            position.x = view.frame.width
        }
        velocity.x = velocity.x * 0.97
        
        characterBaseY.constant = position.y
        characterBaseX.constant = position.x
    }
    
    func jump(){
        velocity.y = 10
    }
    
    func moveLeft(){
        print("moveLeft")
        velocity.x = max(velocity.x - 1, -15)
    }
    
    func moveRight(){
        print("moveRight")
        velocity.x = min(velocity.x + 1, 15)
    }
    
    func moveUp(){
        print("moveUp")
    }
    
    func moveDown(){
        print("moveDown")
    }
    
    func collided(view1: UIView, view2: UIView) -> Bool{
        return view1.frame.intersects(view2.frame)
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

