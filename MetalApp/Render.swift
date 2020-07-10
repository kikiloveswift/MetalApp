//
//  Render.swift
//  MetalApp
//
//  Created by konglee on 2020/7/4.
//

import MetalKit

final class Render: NSObject {
    
    var device: MTLDevice!
    
    var commandQueue: MTLCommandQueue!
    
    var mesh: MTKMesh!
    
    var vertexBuffer: MTLBuffer!
    
    var pipelineState: MTLRenderPipelineState!
    
    var metalView: MTKView!
    
    var timer: Float = 0
    
    override init() {
        super.init()
    }
    
    convenience init(mView: MTKView) {
        self.init()
        guard let dvc = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        device = dvc
        metalView = mView
        metalView.device = device
        metalView.clearColor = MTLClearColor(red: 1.0,
                                             green: 1.0,
                                             blue: 0.3,
                                             alpha: 1.0)
        metalView.delegate = self
        guard let cqueue = device.makeCommandQueue() else {
            return
        }
        commandQueue = cqueue
        
        let mdlMesh = Primitive.makeCube(device: device, size: 0.6)
        
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch {
            print(error.localizedDescription)
        }
        
        // set VertextBuffer
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        /// bind Library
        let library = device.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "vertex_main")
        let fragmentFunc = library?.makeFunction(name: "fragment_main")
        
        /// Creat pipeline state
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
//        do {
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch {
//            fatalError(error.localizedDescription)
//        }
        
        guard let pipe = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            return
        }
        pipelineState = pipe
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension Render: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        
        /// draw code
        /// This set up a render command encoder and presents the view's drawable texture to the GPU
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        timer += 0.05
        var currentTime = sin(timer)
        renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .point,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
