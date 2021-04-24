
#if os(iOS)
import UIKit
typealias NSUIViewController = UIViewController
#elseif os(macOS)
import Cocoa
typealias NSUIViewController = NSViewController
#endif

import MetalKit
import ModelIO
import MobileCoreServices
import ReplayKit

class ViewController: NSUIViewController, UIDocumentPickerDelegate, RPPreviewViewControllerDelegate {
    var renderer: Renderer!
    var cameraController: CameraController!
    let screenRecorder = RPScreenRecorder.shared()
    @IBOutlet weak var recordBtn: UIBarButtonItem!
    @IBOutlet weak var micBtn: UIBarButtonItem!
    var mtkView: MTKView {
        return view as! MTKView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.clearColor = MTLClearColorMake(0.3, 0.3, 0.3, 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.sampleCount = 4
        
        renderer = Renderer(view: mtkView, device: device)
        mtkView.delegate = renderer

        mtkView.framebufferOnly = false
        cameraController = CameraController()
        renderer.viewMatrix = cameraController.viewMatrix
    }
    
    func OnSnapShotCapture() {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let pv = storyboard.instantiateViewController(withIdentifier: "PreView") as! PreviewViewController
        self.present(pv, animated: true, completion: nil)
        let capturedInage = UIImage.init(cgImage: (mtkView.currentDrawable?.texture.toImage()!)!)
        pv.SetImage(image: capturedInage)
    }
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

    @IBAction func OnGoldType(_ sender: UIBarButtonItem) {
        
        switch sender.tag {
        case 100:
            renderer.setBaeColor(color: float4(1.0, 0.85, 0.57, 1.0))
            break;
        case 101:
            renderer.setBaeColor(color: float4(0.97, 0.96, 0.91, 1.0))
            break;
        case 102:
            renderer.setBaeColor(color: float4(0.80, 0.49, 0.19, 1.0))
            break;
        case 103:
            renderer.setBaeColor(color: float4(1.0, 0.0, 0.0, 1.0))
            break;
        case 104:
            renderer.setBaeColor(color: float4(0.0, 0.0, 1.0, 1.0))
            break;
        case 105:
            renderer.setBaeColor(color: float4(0.83, 0.83, 0.83, 1.0))
            break;
        default:
            break;
        }
    }
    
    @available(iOS 13.0, *)
    func OnScreenRecord() {
        
        if(screenRecorder.isRecording == true)
        {
            screenRecorder.stopRecording { (replayVC_: RPPreviewViewController?, error_: Error?) in
             
                //
                replayVC_?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(replayVC_!, animated: true, completion: nil)
                replayVC_?.previewControllerDelegate = self
                self.recordBtn.image = UIImage(systemName: "record.circle")
                
            }
            return
        }
        self.micBtn.isEnabled = true
        
        self.recordBtn.image = UIImage(systemName: "stop.circle.fill")
        //button.setImage(, for: .normal)
        //button.setImage(boldSearch, for: .normal)
        screenRecorder.startRecording { [unowned self](error) in
            
            self.micBtn.image = UIImage(systemName: "mic")
            if(screenRecorder.isMicrophoneEnabled == true)
            {
                self.micBtn.image = UIImage(systemName: "mic.slash")
            }
            
        }
    }
    
    @IBAction func OnToolButton(_ sender: UIBarButtonItem) {
        
        
        switch sender.tag
        {
        case 1000:
            do {
                let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
                self.present(documentPicker, animated: true)
                documentPicker.delegate = self
            }
            break;
        case 1001:
            do{
                renderer.Undo()
            }
            break;
        case 1002:
            renderer.DeleteAll()
            break;
        case 1003:
            OnSnapShotCapture()
            break
        case 1004:
            if #available(iOS 13.0, *) {
                OnScreenRecord()
            } else {
                // Fallback on earlier versions
            }
            break
        case 1005:
            do
            {
               // if(screenRecorder.isRecording == true)
               // {
                    screenRecorder.isMicrophoneEnabled = !screenRecorder.isMicrophoneEnabled
                    if #available(iOS 13.0, *) {
                        self.micBtn.image = UIImage(systemName: "mic")
                    } else {
                        // Fallback on earlier versions
                    }
                    if(screenRecorder.isMicrophoneEnabled == true)
                    {
                        if #available(iOS 13.0, *) {
                            self.micBtn.image = UIImage(systemName: "mic.slash")
                        } else {
                            // Fallback on earlier versions
                        }
                    }
               // }
            }
            break
        default:
            
            break;
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
       
        renderer.LoadModelAtUrl(url: urls[0])
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController)
    {
        previewController.dismiss(animated: true, completion: nil)
    }

    #if os(iOS)
    var trackedTouch: UITouch?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackedTouch == nil {
            if let newlyTrackedTouch = touches.first {
                trackedTouch = newlyTrackedTouch
                let point = newlyTrackedTouch.location(in: view)
                cameraController.startedInteraction(at: point)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let previouslyTrackedTouch = trackedTouch {
            if touches.contains(previouslyTrackedTouch) {
                let point = previouslyTrackedTouch.location(in: view)
                cameraController.dragged(to: point)
                renderer.viewMatrix = cameraController.viewMatrix
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let previouslyTrackedTouch = trackedTouch {
            if touches.contains(previouslyTrackedTouch) {
                self.trackedTouch = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let previouslyTrackedTouch = trackedTouch {
            if touches.contains(previouslyTrackedTouch) {
                self.trackedTouch = nil
            }
        }
    }
    
    
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        var point = view.convert(event.locationInWindow, from: nil)
        point.y = view.bounds.size.height - point.y
        cameraController.startedInteraction(at: point)
    }

    override func mouseDragged(with event: NSEvent) {
        var point = view.convert(event.locationInWindow, from: nil)
        point.y = view.bounds.size.height - point.y
        cameraController.dragged(to: point)
        renderer.viewMatrix = cameraController.viewMatrix
    }
#endif
}

