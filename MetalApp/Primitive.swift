//
//  Primitive.swift
//  MetalApp
//
//  Created by konglee on 2020/7/5.
//

import MetalKit

final class Primitive {
    
    class func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(sphereWithExtent: vector_float3(x: size, y: size, z: size),
                           segments: vector_uint2(x: 100, y: 100),
                           inwardNormals: false,
                           geometryType: .triangles,
                           allocator: allocator)
        return mesh
    }
    
}
