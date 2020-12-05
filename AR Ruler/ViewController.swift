//
//  ViewController.swift
//  AR Ruler
//
//  Created by Bing Xiong on 12/5/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // 点击屏幕回调
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch detected!")
        // 如果点击了三次就进行重置
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    // 添加圆点
    func addDot(at hitResult : ARHitTestResult){
        // 创建一个半径为0.005的球体
        let dotGeometry = SCNSphere(radius: 0.005)
        // 创建一个红色的材料
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        // 将材料赋值给这个球体
        dotGeometry.materials = [material]
        
        // 将之前创建的球体和材料结合起来成一个Node
        let dotNode = SCNNode(geometry: dotGeometry)
        
        // 设置该Node的位置
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        // 在场景中将该Node显示出来
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        // 在总的dotNodes的array中添加
        dotNodes.append(dotNode)
        
        // 当总的node超过两个时 计算距离
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position) // SCNVector3(x: 0.032717623, y: -0.23782218, z: -0.15081623)
        print(end.position) // SCNVector3(x: -0.065903306, y: -0.2283419, z: -0.12530085)
        
        let distance = sqrt(
                pow(end.position.x - start.position.x, 2) +
                pow(end.position.y - start.position.y, 2) +
                pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
        
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        // 如果之前有文字就清除掉
        textNode.removeFromParentNode()
        // 创建一个3D文字 厚度为1 如果设置为0将是一个2D文字
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        // 快捷设置文字的颜色
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        // 创建文字的Node以及文字
        textNode = SCNNode(geometry: textGeometry)
        // 设置文字的位置
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        // 将文字缩放到
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        // 添加到场景
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
