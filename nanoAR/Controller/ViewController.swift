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
    let characterOffset: SIMD3<Float> = [0, 0, 0]
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
    
    var acttrButton: ModelEntity?
    let acttrbOffset: SIMD3<Float> = [0.8,0.6,0]
    var acttrbAnchor = AnchorEntity()
    
    var acttlButton: ModelEntity?
    let acttlbOffset: SIMD3<Float> = [-0.8,0.6,0]
    var acttlbAnchor = AnchorEntity()
    
    var actbrButton: ModelEntity?
    let actbrbOffset: SIMD3<Float> = [0.8,-0.6,0]
    var actbrbAnchor = AnchorEntity()
    
    var actblButton: ModelEntity?
    let actblbOffset: SIMD3<Float> = [-0.8,-0.6,0]
    var actblbAnchor = AnchorEntity()
    
    let motion = PhysicsBodyComponent()
    let collision = CollisionComponent(shapes: [.generateBox(size: [1.05,1.05,1.05])])
    var simpleMaterial = SimpleMaterial(color: .black, isMetallic: true)
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
        
        arView.scene.addAnchor(acttrbAnchor)
        arView.scene.addAnchor(acttlbAnchor)
        arView.scene.addAnchor(actbrbAnchor)
        arView.scene.addAnchor(actblbAnchor)

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
        cancellableSquare = Entity.loadModelAsync(named: "3dobjects/frame.usdz").sink(
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
        cancellableTRButton = Entity.loadModelAsync(named: "3dobjects/button.usdz").sink(
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
        cancellableTLButton = Entity.loadModelAsync(named: "3dobjects/button.usdz").sink(
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
        cancellableBRButton = Entity.loadModelAsync(named: "3dobjects/button.usdz").sink(
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
        cancellableBLButton = Entity.loadModelAsync(named: "3dobjects/button.usdz").sink(
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
        
        var cancellableactTRButton: AnyCancellable? = nil
        cancellableactTRButton = Entity.loadModelAsync(named: "3dobjects/button2.usdz").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableactTRButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.acttrButton = button
                cancellableactTRButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableactTLButton: AnyCancellable? = nil
        cancellableactTLButton = Entity.loadModelAsync(named: "3dobjects/button2.usdz").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableactTLButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.acttlButton = button
                cancellableactTLButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableactBRButton: AnyCancellable? = nil
        cancellableactBRButton = Entity.loadModelAsync(named: "3dobjects/button2.usdz").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableactBRButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.actbrButton = button
                cancellableactBRButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
        var cancellableactBLButton: AnyCancellable? = nil
        cancellableactBLButton = Entity.loadModelAsync(named: "3dobjects/button2.usdz").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellableactBLButton?.cancel()
        }, receiveValue: { (button: Entity) in
            if let button = button as? ModelEntity {
                // Scale the character to human size
                button.scale = self.buttonScale
                self.actblButton = button
                cancellableactBLButton?.cancel()
            } else {
                print("Error: Unable to load model as Entity")
            }
            
        })
        
//        arView.scene.subscribe(to: CollisionEvents.Began.self) { (collision) in
//
//            collision.entityB.removeFromParent()
//
//            print("\(collision.entityA) has collided with \(collision.entityB)")
//
//            self.acttrbAnchor.addChild(self.acttrButton!)
//            self.acttlbAnchor.addChild(self.acttlButton!)
//            self.actbrbAnchor.addChild(self.actbrButton!)
//            self.actblbAnchor.addChild(self.actblButton!)
//
//            self.buttonRandomizer()
//
//        }.store(in: &cancellables)
//        
//        character?.components.set([motion, collision, body])
//        trButton?.components.set([motion, collision, body])
//        tlButton?.components.set([motion, collision, body])
//        brButton?.components.set([motion, collision, body])
//        blButton?.components.set([motion, collision, body])
        
    }
    
    func buttonRandomizer() {
       let randNum = Int.random(in: (1...4))
        
        switch randNum {
            case 1:
                for button in acttrbAnchor.children {
                    if button == acttrButton {
                        acttrButton?.removeFromParent()
                    }
                }
            trbAnchor.addChild(self.trButton!)
            
            case 2:
            for button in acttlbAnchor.children {
                if button == acttlButton {
                    acttlButton?.removeFromParent()
                }
            }
            tlbAnchor.addChild(self.tlButton!)
            
            case 3:
            for button in actbrbAnchor.children {
                if button == actbrButton {
                    actbrButton?.removeFromParent()
                }
            }
            brbAnchor.addChild(self.brButton!)
            
            case 4:
            for button in actblbAnchor.children {
                if button == actblButton {
                    actblButton?.removeFromParent()
                }
            }
            blbAnchor.addChild(self.blButton!)
            
            default:
            print("Error")
        }
    }
        
     
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
         for anchor in anchors {
             guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            if cancellables.isEmpty {
                arView.scene.subscribe(to: CollisionEvents.Began.self) { (collision) in
                    
                    collision.entityB.removeFromParent()

                    print("\(collision.entityA) has collided with \(collision.entityB)")

                    self.acttrbAnchor.addChild(self.acttrButton!)
                    self.acttlbAnchor.addChild(self.acttlButton!)
                    self.actbrbAnchor.addChild(self.actbrButton!)
                    self.actblbAnchor.addChild(self.actblButton!)

                    self.buttonRandomizer()

                }.store(in: &cancellables)
            }

            character?.components.set([motion, collision, body])
            trButton?.components.set([motion, collision, body])
            tlButton?.components.set([motion, collision, body])
            brButton?.components.set([motion, collision, body])
            blButton?.components.set([motion, collision, body])
        
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            
            characterAnchor.position = bodyPosition + characterOffset
            squareAnchor.position = bodyPosition + squareOffset
            trbAnchor.position = bodyPosition + trbOffset
            tlbAnchor.position = bodyPosition + tlbOffset
            brbAnchor.position = bodyPosition + brbOffset
            blbAnchor.position = bodyPosition + blbOffset
            
            acttrbAnchor.position = bodyPosition + acttrbOffset
            acttlbAnchor.position = bodyPosition + acttlbOffset
            actbrbAnchor.position = bodyPosition + actbrbOffset
            actblbAnchor.position = bodyPosition + actblbOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
            if let character = character, character.parent == nil,
                let square = square, square.parent == nil,
                let trButton = trButton, trButton.parent == nil,
                let tlButton = tlButton, tlButton.parent == nil,
                let brButton = brButton, brButton.parent == nil,
                let blButton = blButton, blButton.parent == nil,
                
                let actblButton = actblButton, actblButton.parent == nil,
                let actbrButton = actbrButton, actbrButton.parent == nil,
                let acttlButton = acttlButton, acttlButton.parent == nil,
                let acttrButton = acttrButton, acttrButton.parent == nil {
                
                characterAnchor.addChild(character)
                squareAnchor.addChild(square)
                acttrbAnchor.addChild(acttrButton)
                acttlbAnchor.addChild(acttlButton)
                actbrbAnchor.addChild(actbrButton)
                actblbAnchor.addChild(actblButton)
                
                self.buttonRandomizer()
                                
                trButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                brButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                tlButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
                blButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
                
                acttrButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                actbrButton.orientation = simd_quatf(angle: .pi/2, axis: [0,0,1])
                acttlButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
                actblButton.orientation = simd_quatf(angle: -(.pi/2), axis: [0,0,1])
            
            }
        }
    }
  
}

