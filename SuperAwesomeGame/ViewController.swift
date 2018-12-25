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

protocol JoyStickDelegate {
    func didGetEvent(_ direction : JoyStick.Direction)
}

class JoyStick : UIImageView, UIGestureRecognizerDelegate{
    var dPadDeadZone: CGFloat = 20.0

    var delegate: JoyStickDelegate?
    
    public enum Direction {
        case center
        case up
        case upRight
        case right
        case downRight
        case down
        case downLeft
        case left
        case upLeft
    }
    
    var dPadLocation: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }
    
    func common(){
        self.addGesture(action: #selector(JoyStick.dPadTouched(_:)), delegate: self)
    }
    
    @objc func dPadTouched(_ rec:UITapGestureRecognizer) {
        dPadLocation = rec.location(in: self)
        if (rec.state == .ended) {
            dPadLocation = nil
        }
        if let dPadLocation = self.dPadLocation {
            calcMove(dPadLocation)
        }
    }
    
    func calcMove(_ location : CGPoint){
        var direction: JoyStick.Direction = .center
        if (location.y < self.frame.size.height/2 - dPadDeadZone){
            direction = .up
            if (location.x < self.frame.size.width/2 - dPadDeadZone){
                direction = .upLeft
            }else if (location.x > self.frame.size.width/2 + dPadDeadZone){
                direction = .upRight
            }
        }else if (location.y > self.frame.size.height/2 + dPadDeadZone){
            direction = .down
            if (location.x < self.frame.size.width/2 - dPadDeadZone){
                direction = .downLeft
            }else if (location.x > self.frame.size.width/2 + dPadDeadZone){
                direction = .downRight
            }
        }else{
            if (location.x < self.frame.size.width/2 - dPadDeadZone){
                direction = .left
            }else if (location.x > self.frame.size.width/2 + dPadDeadZone){
                direction = .right
            }
        }
        delegate?.didGetEvent(direction)
    }
    
}

extension UIView {
    func addGesture(action: Selector?, delegate: UIGestureRecognizerDelegate) {
        let gest = UILongPressGestureRecognizer(target: delegate, action: action)
        gest.delegate = delegate
        gest.minimumPressDuration = 0
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gest)
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, JoyStickDelegate {

    @IBOutlet var character: UIImageView!
    @IBOutlet var characterBaseX: NSLayoutConstraint!
    @IBOutlet var characterBaseY: NSLayoutConstraint!

    var position : Vector = Vector(0, 100)
    var velocity : Vector = Vector(0, 0)
    var acceleration : Vector = Vector(0, 0)
    var gravity : Vector = Vector(0, -0.75)
    var floorForce : Vector = Vector(0, 0)
    
    @IBOutlet var aButton: UIImageView!
    @IBOutlet var bButton: UIImageView!
    @IBOutlet var dPad: JoyStick!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dPad.delegate = self
        start()
    }
    
    func start(){
        aButton.addGesture(action: #selector(ViewController.aTapped(_:)), delegate: self)
        bButton.addGesture(action: #selector(ViewController.bTapped(_:)), delegate: self)
        
        Timer.scheduledTimer(timeInterval: 0.0166666, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    
    @objc func update() {
        
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
    
    func didGetEvent(_ direction: JoyStick.Direction) {
        print(direction)
        switch direction {
        case .left, .downLeft, .upLeft:
            moveLeft()
        case .right, .downRight, .upRight:
            moveRight()
        default:
            break
        }
    }
    
    func collided(view1: UIView, view2: UIView) -> Bool{
        return view1.frame.intersects(view2.frame)
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

}

