//
//  SiriWaveView.swift
//  SiriWave
//
//  Created by politom on 08/03/2019.
//

import Foundation
import UIKit

public class SiriWaveLine {
    
    let GRAPH_X: CGFloat = 25
    let AMPLITUDE_FACTOR: CGFloat = 0.8
    let SPEED_FACTOR: CGFloat = 1
    let DEAD_PX: CGFloat = 2
    let ATT_FACTOR: CGFloat = 4
    let DESPAWN_FACTOR: CGFloat = 0.02
    let NOOFCURVES_RANGES: [CGFloat] = [5, 5]
    let AMPLITUDE_RANGES: [CGFloat] = [0.3, 1]
    let OFFSET_RANGES: [CGFloat] = [-3, 3]
    let WIDTH_RANGES: [CGFloat] = [1, 3]
    let SPEED_RANGES: [CGFloat] = [0.5, 1]
    let DESPAWN_TIMEOUT_RANGES: [CGFloat] = [500, 2000]
    
    var spawnAt: Int = Date().millisecondsSince1970
    var noOfCurves: Int!
    var phases: [CGFloat] = []
    var offsets: [CGFloat] = []
    var speeds: [CGFloat] = []
    var finalAmplitudes: [CGFloat] = []
    var widths: [CGFloat] = []
    var amplitudes: [CGFloat] = []
    var despawnTimeouts: [CGFloat] = []
    var verses: [CGFloat] = []
    var prevMaxY: CGFloat = 0
    
    public private (set) var amplitude: CGFloat
    public private (set) var speed: CGFloat
    public private (set) var pixelDepth: CGFloat
    public private (set) var heightMax: CGFloat
    public private (set) var width: CGFloat
    public private (set) var color: UIColor
    
    public init(amplitude: CGFloat,
                speed: CGFloat,
                pixelDepth: CGFloat,
                width: CGFloat,
                heightMax: CGFloat,
                color: UIColor) {
        
        self.amplitude = amplitude
        self.speed = speed
        self.pixelDepth = pixelDepth
        self.width = width
        self.heightMax = heightMax
        self.color = color
        
        commonInit()
    }
    
    private func commonInit() {
        self.spawnAt = Date().millisecondsSince1970
        self.noOfCurves = Int(floor(getRandomRange(NOOFCURVES_RANGES)))
        
        self.phases = Array(repeating: 0.0, count: noOfCurves)
        self.offsets = Array(repeating: 0.0, count: noOfCurves)
        self.speeds = Array(repeating: 0.0, count: noOfCurves)
        self.finalAmplitudes = Array(repeating: 0.0, count: noOfCurves)
        self.widths = Array(repeating: 0.0, count: noOfCurves)
        self.amplitudes = Array(repeating: 0.0, count: noOfCurves)
        self.despawnTimeouts = Array(repeating: 0.0, count: noOfCurves)
        self.verses = Array(repeating: 0.0, count: noOfCurves)
        
        for ci in 0..<noOfCurves {
            self.respawnSingle(ci)
        }
    }
    
    public func drawLine(_ ctx: CGContext,
                         _ amplitude: CGFloat,
                         _ speed: CGFloat) {
        
        self.amplitude = amplitude
        self.speed = speed
        
        for ci in 0..<noOfCurves {
            if spawnAt + Int(despawnTimeouts[ci]) <= Date().millisecondsSince1970 {
                amplitudes[ci] -= DESPAWN_FACTOR;
            } else {
                amplitudes[ci] += DESPAWN_FACTOR;
            }
            
            amplitudes[ci] = min(max(amplitudes[ci], 0), finalAmplitudes[ci]);
            phases[ci] = (phases[ci] + speed * speeds[ci] * SPEED_FACTOR).truncatingRemainder(dividingBy: (2 * CGFloat.pi))
        }
        
        var maxY = -CGFloat.infinity
        var minX = CGFloat.infinity
        
        for sign in [1, -1] {
            
            ctx.beginPath()
            var i = -GRAPH_X
            while i <= GRAPH_X {
                
                let x = xpos(i)
                let y = ypos(i)
                let newY = heightMax/2 - CGFloat(sign) * y
                
                if(x == 0) {
                    ctx.move(to: CGPoint(x: x,
                                         y: newY))
                } else {
                    ctx.addLine(to: CGPoint(x: x,
                                            y: newY))
                }
                
//                print ("x: \(x), y: \(newY)")
                
                minX = min(minX, x)
                maxY = max(maxY, y)
                
                i = i + pixelDepth
            }
            
            ctx.closePath()
            ctx.setFillColor(color.cgColor)
            ctx.setStrokeColor(color.cgColor)
            ctx.fillPath()
        }
        
        if (maxY < DEAD_PX && prevMaxY > maxY) {
            respawn()
        }
        
        prevMaxY = maxY
    }
    
    private func respawn() {
        commonInit()
    }
    private func respawnSingle(_ ci: Int) {
        self.phases[ci] = 0
        self.amplitudes[ci] = 0
        
        self.despawnTimeouts[ci] = getRandomRange(DESPAWN_TIMEOUT_RANGES)
        self.offsets[ci] = getRandomRange(OFFSET_RANGES)
        self.speeds[ci] = getRandomRange(SPEED_RANGES)
        self.finalAmplitudes[ci] = getRandomRange(AMPLITUDE_RANGES)
        self.widths[ci] = getRandomRange(WIDTH_RANGES)
        self.verses[ci] = getRandomRange([-1, 1])
    }
    private func yRelativePos(_ i: CGFloat) -> CGFloat {
        var y: CGFloat = 0
        
        for ci in 0..<noOfCurves {
            // Generate a static T so that each curve is distant from each oterh
            var t: CGFloat = 4.0 * (-1.0 + (CGFloat(ci) / (CGFloat(noOfCurves) - 1.0) * 2.0))
            // but add a dynamic offset
            t = t + offsets[ci];
            
            let k = 1 / widths[ci];
            let x = (i * k) - t;
            
            y = y + abs(amplitudes[ci] * sinus(verses[ci] * x,
                                               phases[ci]) * globalAttFn(x))
        }
        
        // Divide for NoOfCurves so that y <= 1
        return (y / CGFloat(noOfCurves));
    }
    private func ypos(_ i: CGFloat) -> CGFloat {
        return AMPLITUDE_FACTOR *
            heightMax *
            amplitude *
            yRelativePos(i) *
            globalAttFn(i / GRAPH_X * 2)
    }
    private func xpos(_ i: CGFloat) -> CGFloat {
        return width * ((i + GRAPH_X) / (GRAPH_X * 2))
    }
    
    private func getRandomRange(_ e: [CGFloat]) -> CGFloat {
        return e[0] + (CGFloat.random(in: 0 ..< 1) * (e[1] - e[0]));
    }
    private func globalAttFn(_ x: CGFloat) -> CGFloat {
        return pow((ATT_FACTOR) / (ATT_FACTOR + pow(x, 2)),
                   ATT_FACTOR)
    }
    private func sinus(_ x: CGFloat, _ phase: CGFloat) -> CGFloat {
        return sin(x - phase)
    }
    
}

public class SiriWaveView: UIView {

    public private (set) var pixelDepth: CGFloat = 0.02
    public private (set) var amplitude: CGFloat = 1
    
    @IBInspectable
    public var idleAmplitude: CGFloat = 0.01
    @IBInspectable
    public var speed: CGFloat = 0.4

    public var colors: [UIColor] = [UIColor(red: 15.0/255.0, green: 82.0/255.0, blue: 169.0/255.0, alpha: 1),
                                    UIColor(red: 173.0/255.0, green: 57.0/255.0, blue: 76.0/255.0, alpha: 1),
                                    UIColor(red: 48.0/255.0, green: 220.0/255.0, blue: 155.0/255.0, alpha: 1)]
    
    private var lines: [SiriWaveLine] = []
    
    private var heightMax: CGFloat {
        return self.frame.height
    }
    private var width: CGFloat {
        return self.frame.width
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func update(_ level: CGFloat) {
        
        self.amplitude = fmax(level,
                              idleAmplitude)
        
        self.setNeedsDisplay()
        
    }
    
    override public func draw(_ rect: CGRect) {
        
        if let ctx: CGContext = UIGraphicsGetCurrentContext() {
            ctx.setAlpha(0.7)
            ctx.setBlendMode(.lighten)

            drawSupportLine(ctx)
            
            for line in lines {
                line.drawLine(ctx,
                              amplitude,
                              speed)
            }
        }
    }
    
    private func commonInit() {
        
        for color in colors {
            
            lines.append(SiriWaveLine(amplitude: amplitude,
                                      speed: speed,
                                      pixelDepth: pixelDepth,
                                      width: width,
                                      heightMax: heightMax,
                                      color: color))
        }
        
    }
    
    private func drawSupportLine(_ ctx: CGContext) {
        
        let colors = [UIColor.clear.cgColor,
                      UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor,
                      UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor,
                      UIColor.clear.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 0.1, 1.0, 0.8, 1]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint(x: 0, y: (heightMax/2)-0.5)
        let endPoint = CGPoint(x: 0, y: (heightMax/2)+0.5)
        
        ctx.drawLinearGradient(gradient,
                               start: startPoint,
                               end: endPoint,
                               options: [])
    }
}


