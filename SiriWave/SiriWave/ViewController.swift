//
//  ViewController.swift
//  SiriWave
//
//  Created by politom on 08/03/2019.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var siriWave: SiriWaveView!
    @IBOutlet weak var siriWave2: SiriWaveView!
    @IBOutlet weak var siriWave3: SiriWaveView!
    
    var phase: CGFloat = 0
    var speed: CGFloat = 0.2
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        phase = (phase + (CGFloat.pi / 2) * speed).truncatingRemainder(dividingBy: (2 * CGFloat.pi))
        var ampl: CGFloat = 1
        var speed: CGFloat = 0.2
        //var ctx = UIGraphicsGetCurrentContext()!
        
        func xxx() {
            ampl = lerp(ampl, 10, 0.1)
            speed = lerp(speed, 1, 0.1)
            
            print("ampl: \(ampl), speed: \(speed)")
            
            //self.siriWave.ctx = ctx
            self.siriWave.amplitude = ampl
            self.siriWave.speed = speed
            self.siriWave.color = .red
            self.siriWave.setNeedsDisplay()

            //self.siriWave2.ctx = ctx
            self.siriWave2.amplitude = ampl
            self.siriWave2.speed = speed
            self.siriWave2.color = .green
            self.siriWave2.setNeedsDisplay()

            //self.siriWave3.ctx = ctx
            self.siriWave3.amplitude = ampl
            self.siriWave3.speed = speed
            self.siriWave3.color = .blue
            self.siriWave3.setNeedsDisplay()

        }
        
        setInterval(0.2) {
            
            DispatchQueue.main.async {
                xxx()
            }
            
        }
        
    }


    private func lerp(_ v0: CGFloat, _ v1: CGFloat, _ t: CGFloat) -> CGFloat {
        return v0 * (1 - t) + v1 * t
    }
    func setInterval(_ interval:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }
}

