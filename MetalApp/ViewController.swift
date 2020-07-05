//
//  ViewController.swift
//  MetalApp
//
//  Created by konglee on 2020/7/4.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    var render: Render?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        // Do any additional setup after loading the view.
    }
    
    func setupMetal() {
        guard let metalView = view as? MTKView else {
            fatalError()
        }
        render = Render(mView: metalView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

