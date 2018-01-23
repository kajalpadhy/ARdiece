//
//  ViewController.swift
//  ARdiece
//
//  Created by Kajal on 1/19/18.
//  Copyright © 2018 Kajal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
//        let sphere = SCNSphere(radius: 0.5)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/lisa.JPG")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        
        //print(ARSessionConfiguration.isSupported)
        print(ARWorldTrackingConfiguration.isSupported)

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //When u touch the plane dice create at the same point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{

            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
            addDice(atLocation: hitResult)
            }
        }
    }
    func addDice(atLocation location : ARHitTestResult){
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if  let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x, y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
    }
    
    func roll(dice: SCNNode){
        ////Rotating Our 3D Objects in the Plane
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomz = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                          y: 0,
                                          z: CGFloat(randomz * 5),
                                          duration: 0.5)
        )
    }
    
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        
    }
    }
    
        
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
    rollAll()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    //Remove Our 3D Objects from the AR Scene
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    
    }
    //MARK:- Creating AR SceneView Delegate methord
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else{
            return
        }
       let planeNode = createlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)

        
//        if anchor is ARPlaneAnchor{
//           let planeAnchor = anchor as! ARPlaneAnchor
//
//        }
//        else{
//            return
//        }
    }
  //MARK:- Plane rendering method
    
    func createlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let gridMterial = SCNMaterial()
        gridMterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMterial]
        planeNode.geometry = plane
      return planeNode
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


