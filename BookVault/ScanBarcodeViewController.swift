//
//  ScanBarcodeViewController.swift
//  BookVault
//
//  Created by David Gollasch on 30.01.15.
//  Copyright (c) 2015 David Gollasch, Caroline Rausch. All rights reserved.
//

import Foundation
import RSBarcodes
import UIKit

class ScanBarcodeViewController : RSCodeReaderViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            println(point)
        }
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                println(barcode) //TODO: Barcode kann hier abgefangen werden!
            }
        }
    }
}