//
//  ViewController.swift
//  StrokeStylePlayground
//
//  Created by Ahmad Krisman Ryuzaki on 15/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        guard let img = UIImage(named: "test") else {
            fatalError("Could not load image!!!!")
        }
        
        let scratchOffView = ScratchOffImageView()
        
        
        //  we'll overlay the scratch-off-view on top of the label
        //  so we can see the text "through" the image
        let backgroundLabel = UILabel()
        backgroundLabel.font = .italicSystemFont(ofSize: 36)
        backgroundLabel.text = "This is some text in a label so we can see that the path is clear -- so it appears as if the image is being \"scratched off\""
        backgroundLabel.numberOfLines = 0
        backgroundLabel.textColor = .red
        backgroundLabel.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        [backgroundLabel, scratchOffView].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backgroundLabel.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.7),
            backgroundLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            backgroundLabel.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            
            scratchOffView.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.8),
            scratchOffView.heightAnchor.constraint(equalTo: scratchOffView.widthAnchor, multiplier: 2.0 / 3.0),
            scratchOffView.centerXAnchor.constraint(equalTo: backgroundLabel.centerXAnchor),
            scratchOffView.centerYAnchor.constraint(equalTo: backgroundLabel.centerYAnchor),
        ])
        
    }
}


class ScratchOffImageView: UIView {
    
    public var image: UIImage? {
        didSet {
            self.scratchOffImageLayer.contents = image?.cgImage
        }
    }
    
    // adjust drawing-line-width as desired
    //  or set from
    public var lineWidth: CGFloat = 24.0 {
        didSet {
            maskLayer.lineWidth = lineWidth
        }
    }
    
    private class MyCustomLayer: CALayer {
        
        var myPath: CGPath?
        var lineWidth: CGFloat = 24.0
        
        override func draw(in ctx: CGContext) {
            
            // fill entire layer with solid color
            ctx.setFillColor(UIColor.gray.cgColor)
            ctx.fill(self.bounds);
            
            // we want to "clear" the stroke
            ctx.setStrokeColor(UIColor.clear.cgColor);
            // any color will work, as the mask uses the alpha value
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.setLineWidth(self.lineWidth)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            if let pth = self.myPath {
                ctx.addPath(pth)
            }
            ctx.setBlendMode(.sourceIn)
            ctx.drawPath(using: .fillStroke)
            
        }
        
    }
    
    private let maskPath: UIBezierPath = UIBezierPath()
    private let maskLayer: MyCustomLayer = MyCustomLayer()
    private let scratchOffImageLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        
        let path = UIBezierPath(arcCenter: self.center, radius: 2000, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        scratchOffImageLayer.path = path.cgPath
        scratchOffImageLayer.fillColor = UIColor.red.cgColor
        scratchOffImageLayer.strokeColor = UIColor.red.cgColor
        
        // Important, otherwise you will get a black rectangle
        maskLayer.isOpaque = false
        
        // add the image layer
        layer.addSublayer(scratchOffImageLayer)
        // assign the layer mask
        scratchOffImageLayer.mask = maskLayer
        
        isUserInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    @objc func handlePan(_ panGesture: UIPanGestureRecognizer) {
        let currentPoint = panGesture.location(in: self)
        switch panGesture.state {
        case .began:
            maskPath.move(to: currentPoint)
        case .changed:
            maskPath.addLine(to: currentPoint)
            // update the mask layer path
            maskLayer.myPath = maskPath.cgPath
            // triggers drawInContext
            maskLayer.setNeedsDisplay()
        default:
            print(panGesture.state)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // set frames for mask and image layers
        maskLayer.frame = bounds
        scratchOffImageLayer.frame = bounds
        
        // triggers drawInContext
        maskLayer.setNeedsDisplay()
    }
    
}
