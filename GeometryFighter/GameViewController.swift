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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
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
        scnView.showsStatistics = true
        // 2
        scnView.allowsCameraControl = true
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
        geometry.materials.first?.diffuse.contents = UIColor.random()
        
        let geometryNode = SCNNode(geometry: geometry)
        
        scnScene.rootNode.addChildNode(geometryNode)
        
        //Create physics to shapes adding force
        geometryNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        geometryNode.physicsBody?.applyForce(force, atPosition: position,
                                             impulse: true)
        
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
        } }
    
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

    }
}


