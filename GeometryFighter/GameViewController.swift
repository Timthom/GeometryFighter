//
//  GameViewController.swift
//  GeometryFighter
//
//  Created by Thomas on 2016-09-06.
//  Copyright (c) 2016 Thomas Månsson. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime:NSTimeInterval = 0
    var game = GameHelper.sharedInstance
    var splashNodes:[String:SCNNode] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        //spawnShape()
        setupHUD()
        setupSplash()
        setupSounds()
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func setupView() {
        scnView = self.view as! SCNView
        // 1
       // scnView.showsStatistics = true
        // 2
       // scnView.allowsCameraControl = false
        // 3
        scnView.autoenablesDefaultLighting = true
        // 4 Calling rendering-loop extention to view
        scnView.delegate = self
        // 5 Set view into an endless playing mode
        scnView.playing = true
    }

    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }
    func setupCamera() {
        // 1
        cameraNode = SCNNode()
        // 2
        cameraNode.camera = SCNCamera()
        // 3
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        // 4
        scnScene.rootNode.addChildNode(cameraNode)
    }
    func spawnShape() {
        //Add shapes
        var geometry:SCNGeometry
        
        switch ShapeType.random() {
        case .Box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.5)
        case .Pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .Torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .Cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .Tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        //Add random color to shape
       // geometry.materials.first?.diffuse.contents = UIColor.random()
        
        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        
        
        //Create physics to shapes adding force
        geometryNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        geometryNode.physicsBody?.applyForce(force, atPosition: position,
                                             impulse: true)
        
        let trailEmitter = createTrail(color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        
        if color == UIColor.blackColor() {
            geometryNode.name = "BAD"
            game.playSound(scnScene.rootNode, name: "SpawnBad")
        } else {
            geometryNode.name = "GOOD"
            game.playSound(scnScene.rootNode, name: "SpawnGood")
        }
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    //Remove node-child after object reach out of bounds
    func cleanScene() {
        // 1
        for node in scnScene.rootNode.childNodes {
            // 2
            if node.presentationNode.position.y < -2 {
                // 3
                node.removeFromParentNode()
            }
        }
    }
    
    // 1
    func createTrail(color: UIColor, geometry: SCNGeometry) ->
        SCNParticleSystem {
            // 2
            let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
            // 3
            trail.particleColor = color
            // 4
            trail.emitterShape = geometry
            // 5
            return trail
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func createSplash(name:String, imageFileName:String) -> SCNNode {
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
        splashNode.name = name
        splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
        scnScene.rootNode.addChildNode(splashNode)
        return splashNode
    }
    func showSplash(splashName:String) {
        for (name,node) in splashNodes {
            if name == splashName {
                node.hidden = false
            } else {
                node.hidden = true
            }
        }
    }
    
    func setupSplash() {
        splashNodes["TapToPlay"] = createSplash("TAPTOPLAY",
                                                imageFileName: "GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png")
        splashNodes["GameOver"] = createSplash("GAMEOVER",
                                               imageFileName: "GeometryFighter.scnassets/Textures/GameOver_Diffuse.png")
        showSplash("TapToPlay")
    }
    
    func setupSounds() {
        game.loadSound("ExplodeGood",
                       fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeGood.wav")
        game.loadSound("SpawnGood",
                       fileNamed: "GeometryFighter.scnassets/Sounds/SpawnGood.wav")
        game.loadSound("ExplodeBad",
                       fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound("SpawnBad",
                       fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
        game.loadSound("GameOver",
                       fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }
    

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if game.state == .GameOver {
            return
        }
        
        if game.state == .TapToPlay {
            game.reset()
            game.state = .Playing
            showSplash("")
            return
        }
        
        let touch = touches.first
        let location = touch!.locationInView(scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            
            let result: AnyObject! = hitResults[0]
            
            if result.node.name == "HUD" ||
                result.node.name == "GAMEOVER" ||
                result.node.name == "TAPTOPLAY" {
                return
            } else if result.node.name == "GOOD" {
                handleGoodCollision()
            } else if result.node.name == "BAD" {
                handleBadCollision()
            }
            
            createExplosion(result.node.geometry!,
                            position: result.node.presentationNode.position,
                            rotation: result.node.presentationNode.rotation)
            
            result.node.removeFromParentNode()
        }
    }
    
    func handleGoodCollision() {
        game.score += 1
        game.playSound(scnScene.rootNode, name: "ExplodeGood")
    }
    
    func handleBadCollision() {
        game.lives -= 1
        game.playSound(scnScene.rootNode, name: "ExplodeBad")
        game.shakeNode(cameraNode)
        
        if game.lives <= 0 {
            game.saveState()
            showSplash("GameOver")
            game.playSound(scnScene.rootNode, name: "GameOver")
            game.state = .GameOver
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                self.showSplash("TapToPlay")
                self.game.state = .TapToPlay
                })
        }
    }

    // 1
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        // 2
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .Surface
        // 3
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y,
                                      position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        // 4
        scnScene.addParticleSystem(explosion, withTransform:
            transformMatrix)
    }
    
}

// Extention to Render-loop
// 1 Calling SCNRenderDelegate
extension GameViewController: SCNSceneRendererDelegate {
    // 2 Method to update view
    func renderer(renderer: SCNSceneRenderer, updateAtTime time:
        NSTimeInterval) {
        // 3 Apply the spawnShape method to loop
        if time > spawnTime {
            spawnShape()
            
            spawnTime = time + NSTimeInterval(Float.random(min: 0.2, max: 1.5))
        }
        cleanScene()
        game.updateHUD()
    }
}


