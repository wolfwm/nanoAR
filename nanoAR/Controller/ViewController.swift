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
    
    let buttonScale: SIMD3<Float> = [0.2, 0.2, 0.2]
    
    var trButton: ModelEntity?
    let trbOffset: SIMD3<Float> = [0.8,0.6,0]
    var trbAnchor = AnchorEntity()
    
    var tlButton: ModelEntity?
    let tlbOffset: SIMD3<Float> = [-0.8,0.6,0]
    var tlbAnchor = AnchorEntity()
    
    var brButton: ModelEntity?
    let brbOffset: SIMD3<Float> = [0.8,-0.6,0]
    var brbAnchor = AnchorEntity()

    var blButton: ModelEntity?
    let blbOffset: SIMD3<Float> = [-0.8,-0.6,0]
    var blbAnchor = AnchorEntity()
    
    let motion = PhysicsBodyComponent()
    let collision = CollisionComponent(shapes: [.generateBox(size: [1,1,1])])
    let body = PhysicsBodyComponent(massProperties: .init(mass: 5), material: .default, mode: .static)
    var cancellables = [AnyCancellable]()
    
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
        arView.scene.addAnchor(trbAnchor)
        arView.scene.addAnchor(tlbAnchor)
        arView.scene.addAnchor(brbAnchor)
        arView.scene.addAnchor(blbAnchor)

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
        cancellableSquare = Entity.loadModelAsync(named: "3dobjects/frame.obj").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableSquare?.cancel()
        }, receiveValue: { (square: Entity) in
            if let square = square as? ModelEntity {
                // Scale the character to human size
                square.scale = [1.1, 1.3, 1.3]
                self.square = square
                cancellableSquare?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableTRButton: AnyCancellable? = nil
        cancellableTRButton = Entity.loadModelAsync(named: "3dobjects/button.obj").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableTRButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.trButton = button
                cancellableTRButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableTLButton: AnyCancellable? = nil
        cancellableTLButton = Entity.loadModelAsync(named: "3dobjects/button.obj").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableTLButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.tlButton = button
                cancellableTLButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableBRButton: AnyCancellable? = nil
        cancellableBRButton = Entity.loadModelAsync(named: "3dobjects/button.obj").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableBRButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.brButton = button
                cancellableBRButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableBLButton: AnyCancellable? = nil
        cancellableBLButton = Entity.loadModelAsync(named: "3dobjects/button.obj").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableBLButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.blButton = button
                cancellableBLButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
    }
        
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
         for anchor in anchors {
             guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            arView.scene.subscribe(to: CollisionEvents.Began.self) { (collision) in
                print("\(collision.entityA) colidiou com \(collision.entityB)")
            }.store(in: &cancellables)
            
            character?.components.set([motion, collision, body])
            trButton?.components.set([motion, collision, body])

            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            
            characterAnchor.position = bodyPosition + characterOffset
            squareAnchor.position = bodyPosition + squareOffset
            trbAnchor.position = bodyPosition + trbOffset
            tlbAnchor.position = bodyPosition + tlbOffset
            brbAnchor.position = bodyPosition + brbOffset
            blbAnchor.position = bodyPosition + blbOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
            if let character = character, character.parent == nil, let square = square, square.parent == nil, let trButton = trButton, trButton.parent == nil, let tlButton = tlButton, tlButton.parent == nil, let brButton = brButton, brButton.parent == nil, let blButton = blButton, blButton.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
                squareAnchor.addChild(square)
                trbAnchor.addChild(trButton)
                tlbAnchor.addChild(tlButton)
                brbAnchor.addChild(brButton)
                blbAnchor.addChild(blButton)
                                
                
                trButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                brButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                tlButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
                blButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
            
            }
        }
    }
  
}

