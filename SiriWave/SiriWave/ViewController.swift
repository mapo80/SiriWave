//
//  ViewController.swift
//  SiriWave
//
//  Created by politom on 08/03/2019.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var siriWave: SiriWaveView!
    
    var phase: CGFloat = 0
    var speed: CGFloat = 0.2
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        phase = (phase + (CGFloat.pi / 2) * speed).truncatingRemainder(dividingBy: (2 * CGFloat.pi))
        var ampl: CGFloat = 1
        var speed: CGFloat = 0.2
        
        func xxx() {
            ampl = lerp(ampl, 10, 0.1)
            speed = lerp(speed, 1, 0.1)
            
            print("ampl: \(ampl), speed: \(speed)")
            
            self.siriWave.amplitude = ampl
            self.siriWave.speed = speed
            
            self.siriWave.setNeedsDisplay()

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

