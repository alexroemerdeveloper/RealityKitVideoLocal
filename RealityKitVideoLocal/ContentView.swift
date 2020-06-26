//
//  ContentView.swift
//  RealityKitVideoLocal
//
//  Created by Alexander Römer on 26.06.20.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        spanTV(in: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func spanTV(in arView: ARView) {
        let tvDimension: SIMD3<Float> = [1.23, 0.046, 0.7] //width, thickness, height
        
        //Create TV-Housing
        let housingMesh   = MeshResource.generateBox(size: tvDimension)
        let housingMat    = SimpleMaterial(color: .black, roughness: 0.4, isMetallic: false)
        let housingEntity = ModelEntity(mesh: housingMesh, materials: [housingMat])
        
        //Create TV Screen
        let screenMesh = MeshResource.generatePlane(width: tvDimension.x, depth: tvDimension.z)
        let screenMaterial = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
        let screenEntity = ModelEntity(mesh: screenMesh, materials: [screenMaterial])
        screenEntity.name = "tvScreen"
        
        //Add TV Screen to Housing
        housingEntity.addChild(screenEntity)
        screenEntity.setPosition([0, tvDimension.y / 2 + 0.001, 0], relativeTo: housingEntity)
        
        //Create  anchor to place tv on the wall
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(housingEntity)
        arView.addAnchor(anchor)
        arView.enableTapGesture()
        housingEntity.generateCollisionShapes(recursive: true)
    }
    
}



extension ARView {
    func enableTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
            loadingVideoMaterial(for: entity)
        }
    }
    
    func loadingVideoMaterial(for entity: ModelEntity) {
        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "mp4")!)
        //get from https://pixabay.com/de/videos/kirche-religion-gott-licht-heilig-42472/
        //video from Caelan Kelley / Pixabay
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer()
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
}






#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
