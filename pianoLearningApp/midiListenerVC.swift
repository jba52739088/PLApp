//
//  ViewController.swift
//  MidiTest1
//
//  Created by 趙令文 on 2018/8/17.
//  Copyright © 2018年 趙令文. All rights reserved.
//

import UIKit
import AudioKit

class midiListenerVC: UIViewController, AKMIDIListener {
    let midi = AKMIDI()
    var i:UInt8 = 36
    let ms = 1000
    
    @IBOutlet weak var value1: UILabel!
    @IBAction func test1(_ sender: Any) {
        i += 1
        let event = AKMIDIEvent.init(noteOn: i, velocity: 93, channel: 0)
        midi.sendEvent(event)
    }
    
    @IBAction func test2(_ sender: Any) {
        let event1 = AKMIDIEvent.init(noteOn: 67, velocity: 40, channel: 0)
        midi.sendEvent(event1)
        usleep(useconds_t(500 * ms))
        let event2 = AKMIDIEvent.init(noteOn: 64, velocity: 40, channel: 0)
        midi.sendEvent(event2)
        usleep(useconds_t(500 * ms))
        let event3 = AKMIDIEvent.init(noteOn: 64, velocity: 40, channel: 0)
        midi.sendEvent(event3)
        usleep(useconds_t(500 * ms))
        
        usleep(useconds_t(1000 * ms))
        
        let event4 = AKMIDIEvent.init(noteOn: 65, velocity: 40, channel: 0)
        midi.sendEvent(event4)
        usleep(useconds_t(500 * ms))
        let event5 = AKMIDIEvent.init(noteOn: 62, velocity: 40, channel: 0)
        midi.sendEvent(event5)
        usleep(useconds_t(500 * ms))
        let event6 = AKMIDIEvent.init(noteOn: 62, velocity: 40, channel: 0)
        midi.sendEvent(event6)
        usleep(useconds_t(500 * ms))
        
        usleep(useconds_t(1000 * ms))
        
        let event7 = AKMIDIEvent.init(noteOn: 60, velocity: 40, channel: 0)
        midi.sendEvent(event7)
        usleep(useconds_t(500 * ms))
        let event8 = AKMIDIEvent.init(noteOn: 62, velocity: 40, channel: 0)
        midi.sendEvent(event8)
        usleep(useconds_t(500 * ms))
        let event9 = AKMIDIEvent.init(noteOn: 64, velocity: 40, channel: 0)
        midi.sendEvent(event9)
        usleep(useconds_t(500 * ms))
        let event10 = AKMIDIEvent.init(noteOn: 65, velocity: 40, channel: 0)
        midi.sendEvent(event10)
        usleep(useconds_t(500 * ms))
        
        let event11 = AKMIDIEvent.init(noteOn: 67, velocity: 40, channel: 0)
        midi.sendEvent(event11)
        usleep(useconds_t(500 * ms))
        let event12 = AKMIDIEvent.init(noteOn: 67, velocity: 40, channel: 0)
        midi.sendEvent(event12)
        usleep(useconds_t(500 * ms))
        let event13 = AKMIDIEvent.init(noteOn: 67, velocity: 40, channel: 0)
        midi.sendEvent(event13)
        usleep(useconds_t(500 * ms))
        
        
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.value1.text = "Key: " + String(noteNumber) + "; " +
                "Speed: " + String(velocity)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        midi.addListener(self)
        midi.openInput()
        let ends:[EndpointInfo] = midi.destinationInfos
        for endpoint in ends {
            print(endpoint.name + ":" + endpoint.displayName)
        }
        
        midi.openOutput("連接埠 1")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

