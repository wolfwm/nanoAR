//
//  ViewController.swift
//  nanoAR
//
//  Created by Wolfgang Walder on 14/02/20.
//  Copyright © 2020 Wolfgang Walder. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    var square: ModelEntity?
    let squareOffset: SIMD3<Float> = [0,0,0]
    var squareAnchor = AnchorEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        arView.scene.addAnchor(squareAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
        
        var cancellableSquare: AnyCancellable? = nil
              cancellableSquare = Entity.loadModelAsync(named: "3dobjects/square").sink(
                  receiveCompletion: { completion in
                      if case let .failure(error) = completion {
                          print("Error: Unable to load model: \(error.localizedDescription)")
                      }
                      cancellableSquare?.cancel()
              }, receiveValue: { (square: Entity) in
                  if let square = square as? ModelEntity {
                      // Scale the character to human size
                    square.scale = [1, 1, 1]
                      self.square = square
                      cancellableSquare?.cancel()
                  } else {
                      print("Error: Unable to load model as BodyTrackedEntity")
                  }
              })
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARBodyAnchor {
                let newAnchor = ARAnchor(name: "box", transform: anchor.transform)
                arView.session.add(anchor: newAnchor)
            }
            else if anchor.name == "box" {
                squareAnchor = AnchorEntity(anchor: anchor)
                let square = ModelEntity(mesh: (self.square?.model!.mesh)!, materials: [SimpleMaterial.init(color: .black, isMetallic: false)])
//                square.position = [0,0,0]
                arView.scene.addAnchor(squareAnchor)
                squareAnchor.addChild(square)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
         for anchor in anchors {
             guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
             
             // Update the position of the character anchor's position.
             let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
             characterAnchor.position = bodyPosition + characterOffset
             // Also copy over the rotation of the body anchor, because the skeleton's pose
             // in the world is relative to the body anchor's rotation.
             characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
             if let character = character, character.parent == nil {
                 // Attach the character to its anchor as soon as
                 // 1. the body anchor was detected and
                 // 2. the character was loaded.
                 characterAnchor.addChild(character)
             }
         }
     }
}
