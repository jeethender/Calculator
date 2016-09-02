//
//  ViewController.swift
//  Calculator01
//
//  Created by maisapride8 on 03/06/16.
//  Copyright © 2016 maisapride8. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    
    private var isUserInTheMiddleOfFloatingPointNumber = false
    private  var isUserInTheMiddleOfTyping = false{
        didSet{
            if !isUserInTheMiddleOfTyping {
                isUserInTheMiddleOfFloatingPointNumber = false
            }
        }
    }
    
    // if user touches the numeric buttons this logic will executes
    @IBAction private func touchDigit(sender: UIButton)     {
        
        var digit = sender.currentTitle! //It takes the title of the button which ever the user touched.
        
        if digit == "." {
            if isUserInTheMiddleOfFloatingPointNumber{
                return
            }
            if !isUserInTheMiddleOfTyping {
                digit = "0."
            }
            isUserInTheMiddleOfFloatingPointNumber = true
        }
        
        
        if isUserInTheMiddleOfTyping
        {
            let textCurrentlyInDisplay = display.text // takes the current value of the  display label text
            display.text = textCurrentlyInDisplay! + digit
        } else {
            display.text = digit
        }
        isUserInTheMiddleOfTyping = true
    }
    
    
    private var displayValue: Double? {
        get {
            if let text = display.text, value = Double(text){
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text =  String(value)
                history.text = brain.description + (brain.isPartialResult ? "..." : "=")
            }else {
                display.text = "0"
                history.text = " "
                isUserInTheMiddleOfTyping = false
            }
        }
    }
    
    var savedProgram: CalculatorBrain.propertylist?
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    
    @IBAction func restore() {
        if savedProgram != nil{
            brain.program = savedProgram!
            displayValue = brain.result
            
        }
    }
    
    // if user touches the generic contant mathematical symbols(ex:π, ∞) this logic will executes
    
    private var brain = CalculatorBrain()
    @IBAction private func performOperation(sender: UIButton)
    {
        if isUserInTheMiddleOfTyping
        {
            brain.setOperand(displayValue!) // if the userinmiddle of typing set operand whatever is in the dispaly
            
            isUserInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle
        {
            brain.performOperation(mathematicalSymbol) // send the mathematicalsymbol to calculator brain
        }
        displayValue = brain.result
        
    }
    //MARK: Assignment tasks
    
    
    @IBAction func backSpace(sender: UIButton) {
        
        if isUserInTheMiddleOfTyping {
            if var text = display.text {
                text.removeAtIndex(text.endIndex.predecessor())
                if text.isEmpty{
                    text = "0"
                    isUserInTheMiddleOfTyping = false
                }else{
                    display.text = text
                }
            }
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        
        isUserInTheMiddleOfTyping = false
        brain.clear()
        displayValue  = nil
        display.text = "0"
        history.text = "0"
    }
}

