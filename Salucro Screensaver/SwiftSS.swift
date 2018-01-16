import ScreenSaver
import SpriteKit

class SwiftSS: ScreenSaverView {
    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()
    
    override func viewWillMove(toSuperview: NSView?) {
        var width, height : CGFloat
        if (toSuperview == nil) {
            width = 640
            height = 480
        } else {
            width = toSuperview!.bounds.width
            height = toSuperview!.bounds.height
        }

        let scene = GameScene(size: CGSize(width: width, height: height))

        let sceneView = SKView(frame: CGRect(x:0 , y:0, width: width, height: height))
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.backgroundColor = SKColor.init(red:0.13, green:0.27, blue:0.44, alpha:1.0)
        
        sceneView.presentScene(scene)
        
        self.addSubview(sceneView)
        
        // Allow keyboard events to inturrupt screensaver
        // without this, only the SHIFT key deactivates the screensaver
        scene.nextResponder = self
    }
    
    override func hasConfigureSheet() -> Bool {
        // Ideally I'd like a configuration sheet to show up
        // with different options for heads
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return sheetController.window
    }
}
