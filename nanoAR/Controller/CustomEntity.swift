////
////  CustomEntity.swift
////  nanoAR
////
////  Created by Mariana Lima on 19/02/20.
////  Copyright © 2020 Wolfgang Walder. All rights reserved.
////
//
//import Foundation
//import UIKit
//import RealityKit
//
//class CustomEntity: Entity, HasModel, HasCollision {
//    required init(modelPath: String, color: UIColor) {
//    super.init()
//        if let modelMesh = Entity.loadModel(named: modelPath).model?.mesh {
//    self.model = ModelComponent(
//        mesh: modelMesh, materials: [SimpleMaterial(
//        color: color,
//        isMetallic: false)
//      ]
//    )
//        }
//    self.generateCollisionShapes(recursive: true)
//  }
//    
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//}
