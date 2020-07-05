/// 可以随时看到 live views
import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not Supported")
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.7, alpha: 1)

/**
 Model I/O
 */

/// allocator 管理这个 mesh data 的内存
/// Model I/O 创建一个球形，并给定了尺寸，并且返回一个 MDLMesh，包含了所有顶点数据
/// Metal 只能使用 Mesh, 所以需要转换一下
let allocator = MTKMeshBufferAllocator(device: device)
let mdlMesh = MDLMesh(coneWithExtent: [1, 1, 1],
                      segments: [10, 10],
                      inwardNormals: false,
                      cap: true,
                      geometryType: .triangles,
                      allocator: allocator)
let mesh = try MTKMesh(mesh: mdlMesh, device: device)

/**
 Queue, buffer and encoder
 1. 你提交给 GPU 的每一帧包含了很多命令，你把这些命令包装起来丢给一个渲染的 comand encoder
 Command buffer 给这些  command encoders 安排一个 command queue
 
 */

guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

/// device 和 command queue 需要在启动 App 的时候已经设定好，并且你要使用同一个 device 和 command queue
/// 在每一帧，你会创建一个 command buffer 和 至少一个 command encoder，这些都是比较轻量的对象，这些轻量级对象指向其他对象，例如着色器功能和管道状态，您只需在应用程序启动时设置一次即可。

/**
 Shader Functions
 */
let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertextIn {
    float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertextIn vertex_in [[stage_in]]) {
    return  vertex_in.position;
}

fragment float4 fragment_main() {
    return  float4(0, 1, 0, 1);
}

"""

let library = try device.makeLibrary(source: shader, options: nil)
let vertextFunc = library.makeFunction(name: "vertex_main")
let fragmentFunc = library.makeFunction(name: "fragment_main")

/**
 The Pipeline State
 Pipeline State 是用来告诉 GPU 啥都不要干除非状态改变，因此这个 GPU 工作会更加有效率，
 */

let descriptor = MTLRenderPipelineDescriptor()
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
descriptor.vertexFunction = vertextFunc
descriptor.fragmentFunction = fragmentFunc

/// MTLVertexDescriptor  MDLVertexDescriptor
descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

/**
 Rending
 */

guard let commandBuffer = commandQueue.makeCommandBuffer(),
    let passDescriptor = view.currentRenderPassDescriptor,
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
        fatalError()
}

renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

guard let submesh = mesh.submeshes.first else {
    fatalError()
}
renderEncoder.setTriangleFillMode(.lines)

renderEncoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount: submesh.indexCount,
                                    indexType: submesh.indexType,
                                    indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)
renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError()
}

commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view

