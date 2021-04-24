
import QuartzCore
import simd
class CameraController {
    var viewMatrix: float4x4 {
        return float4x4(translationBy: float3(0, 0, -radius)) *
               float4x4(rotationAbout: float3(1, 0, 0), by: altitude) *
               float4x4(rotationAbout: float3(0, 1, 0), by: azimuth)
        
    }
    
    var radius: Float = 65
    var sensitivity: Float = 0.01
    let minAltitude: Float = -.pi / 4
    let maxAltitude: Float = .pi / 2
    var mViewMatrix = matrix_identity_float4x4
    var mXTrans : Float = 0
    var mYTrans : Float = 0
    private var altitude: Float = 0
    private var azimuth: Float = 0

    private var lastPoint: CGPoint = .zero
    
    func startedInteraction(at point: CGPoint) {
        lastPoint = point
    }
    
    func dragged(to point: CGPoint) {
        let deltaX = Float(lastPoint.x - point.x)
        let deltaY = Float(lastPoint.y - point.y)
        azimuth += -deltaX * sensitivity
        altitude += -deltaY * sensitivity
      //  altitude = min(max(minAltitude, altitude), maxAltitude)
        lastPoint = point
    }
    
    func Rotate(deltaPt: CGPoint)
    {
        azimuth += Float(deltaPt.x) * sensitivity
        altitude += Float(deltaPt.y) * sensitivity
    }
    
    func GetViewMatrix() -> float4x4 {
        
        let transMatrix = float4x4(translationBy: float3(mXTrans, mYTrans, -radius))
        let xRotMatrix = float4x4(rotationAbout: float3(1, 0, 0), by: altitude)
        let yRotMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: azimuth)
        //let dragMatrix = float4x4(translationBy: float3(mXTrans, mYTrans, 0.0))
//
        return transMatrix * xRotMatrix * yRotMatrix
        //return mViewMatrix
    }
    
    func Drag(pt : CGPoint) {
        
        let dragSensititvity = sensitivity * 2
        mXTrans += Float(pt.x * CGFloat(dragSensititvity))
        mYTrans -= Float(pt.y * CGFloat(dragSensititvity))
    }
    
    func Zoom(val : Float) {
        
        radius += val
    }
    
    func Reset() {
        
        radius = 60
        mXTrans = 0
        mYTrans = 0
        azimuth = 0
        altitude = 0
    }
}
