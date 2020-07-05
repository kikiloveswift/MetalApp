//
//  shaderDemo.metal
//  MetalApp
//
//  Created by konglee on 2020/7/4.
//

#include <metal_stdlib>
using namespace metal;

struct VertextIn {
    float4 position [[attribute(0)]];
};

struct VertextOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

//vertex float4 vertex_main(const VertextIn vertex_in [[stage_in]], constant float &timer[[buffer(1)]]) {
//    float4 position = vertex_in.position;
//    position.y += timer;
//    return  position;
//}

vertex VertextOut vertex_main(constant float3 *vertices [[ buffer(0) ]], uint vid [[ vertex_id ]]) {
    VertextOut vertex_out;
    vertex_out.position = float4(vertices[vid], 1);
    vertex_out.point_size = 20.0;
    return vertex_out;
}


//fragment float4 fragment_main() {
//    return  float4(1, 0, 0, 1);
//}

fragment float4 fragment_main(constant float4 &color [[ buffer(0) ]]) {
    return color;
}
