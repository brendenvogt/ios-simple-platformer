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

    var yPos : NSLayoutConstraint?
    
    lazy var character: UIImageView = {
        let size: CGFloat = 80.0
        let offset: CGFloat = 25.0
        var v = UIImageView(frame: CGRect(x: 200, y: view.frame.size.height-size-offset, width: size, height: size))
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "dinoJump")
        return v
    }()

    lazy var ground: UIImageView = {
        let height : CGFloat = 50.0
        let width : CGFloat = 3000.0
        var v = UIImageView(frame: CGRect(x: 0, y: view.frame.size.height-height, width: width, height: height))
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "dinoGround")
        return v
    }()

    lazy var aButton: UIImageView = {
        let size : CGFloat = 75.0
        let offset : CGFloat = 25.0
        let spacing : CGFloat = 10.0
        var v = UIImageView(frame: CGRect(x: view.frame.size.width-offset-1*(spacing+size), y: self.view.frame.size.height-size-offset-0.5*size, width: 75, height: 75))
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "flatDark35")
        v.alpha = 0.75
        v.addGesture(action: #selector(ViewController.aTapped(_:)), delegate: self)
        return v
    }()
    
    lazy var bButton: UIImageView = {
        let size : CGFloat = 75.0
        let offset : CGFloat = 25.0
        let spacing : CGFloat = 10.0
        var v = UIImageView(frame: CGRect(x: view.frame.size.width-offset-2*(spacing+size), y: self.view.frame.size.height-size-offset, width: size, height: size))
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "flatDark36")
        v.alpha = 0.75
        v.addGesture(action: #selector(ViewController.bTapped(_:)), delegate: self)
        return v
    }()
    
    lazy var dPad: JoyStick = {
        let size : CGFloat = 150.0
        let offset : CGFloat = 25.0
        var j = JoyStick(frame: CGRect(x: offset, y: self.view.frame.size.height-size-offset, width: size, height: size))
        j.image = UIImage(named: "flatDark08")
        j.alpha = 0.75
        return j
    }()
    
    var moveCounter : CGFloat = 0.0
    var dinoCounter : CGFloat = 0.0
    var isJumping : Bool = false
    var isGoing : Bool = false
    var isDead : Bool = false
    var gameAcceleration : Vector = Vector(-0.003, 0)
    
    var obstacles : [UIView] = []
    
    var position : Vector = Vector(0, 25)
    var velocity : Vector = Vector(-8, 0)
    var acceleration : Vector = Vector(0, 0)
    var gravity : Vector = Vector(0, -0.75)
    
    var jumpForce : Vector = Vector(0, 14)
    var floorForce : Vector = Vector(0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dPad.delegate = self
        start()
    }
    
    func start(){

        view.addSubview(ground)
        
        view.addSubview(character)
        
        view.addSubview(aButton)
        //view.addSubview(bButton)
        //view.addSubview(dPad)
        
        Timer.scheduledTimer(timeInterval: 0.0166666, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    func convertPosition(_ vector: Vector, forCharacter character: UIView)-> Vector{
        return Vector(vector.x, self.view.frame.size.height-vector.y-character.frame.size.height)
    }
    
    @objc func update() {
        
        updateDino()

        if isGoing == false {
            return
        }
        
        position = position + velocity
        velocity = velocity + acceleration
        acceleration = gravity + floorForce + gameAcceleration
    
        if (position.y <= 25){
            floorForce = Vector(0, -gravity.y)
            velocity.y = 0
            position.y = 25
            landed()
        }else{
            floorForce = Vector.zero
        }
    
        //ground movement
        if (position.x < -ground.frame.width+view.frame.width){
            position.x = 0
        }
        
        if (moveCounter <= 0){
            moveCounter = CGFloat(Int(arc4random()) % 1000 + 2000)
            spawnRandomObst()
        }else{
            moveCounter = moveCounter - abs(velocity.x)
        }
        
        for obst in obstacles {
            obst.center.x = obst.center.x + velocity.x
            
            if (collided(view1: obst, view2: character)){
                isGoing = false
                isDead = true
            }
            
            if obst.center.x < -100 {
                obst.removeFromSuperview()
            }
        }
        
        character.center.y = convertPosition(position, forCharacter: character).y + character.frame.size.height/2
        ground.center.x = position.x + ground.frame.size.width/2
        
    }
    
    func spawnRandomObst(){
        let obstNames : [String:CGSize] = [
            "dinoCact1":CGSize(width: 46, height: 92),
            "dinoCact2":CGSize(width: 30, height: 66),
            "dinoCact3":CGSize(width: 96, height: 66),
            "dinoCact4":CGSize(width: 146, height: 94)
        ]
        let item = obstNames.randomElement()!
        let obst = UIImageView(frame: .init( x: -ground.frame.origin.x + view.frame.size.width, y: view.frame.size.height-item.value.height-25, width: item.value.width, height: item.value.height))
        obst.contentMode = .scaleAspectFit
        obst.image = UIImage(named: item.key)
        view.addSubview(obst)
        obstacles.append(obst)
    }
    
    func updateDino(){
        let dinoLimit: CGFloat = 100.0
        if isDead {
            character.image = UIImage(named: "dinoDead")
            return
        }
        if isGoing == false || isJumping {
            character.image = UIImage(named: "dinoJump")
            return
        }
        dinoCounter = dinoCounter + abs(velocity.x)
        if dinoCounter < dinoLimit {
            //dino1
            character.image = UIImage(named: "dino0")
        }else if dinoCounter < dinoLimit * 2{
            //dino2
            character.image = UIImage(named: "dino1")
        }else{
            dinoCounter = 0
        }
    }
    
    func landed(){
        isJumping = false
    }
    func jump(){
        if (isJumping){
            return
        }
        isJumping = true
        velocity.y = jumpForce.y
    }
    
    func moveLeft(){
        velocity.x = max(velocity.x - 1, -15)
    }
    
    func moveRight(){
        velocity.x = min(velocity.x + 1, 15)
    }
    
    func moveUp(){
    }
    
    func moveDown(){
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
            if isDead {
                //restart
                for obst in obstacles {
                    obst.removeFromSuperview()
                }
                obstacles.removeAll()
                velocity.x = -8
                isDead = false
            }
            if isGoing == false {
                isGoing = true
                return
            }
            jump()
        }
    }

}

