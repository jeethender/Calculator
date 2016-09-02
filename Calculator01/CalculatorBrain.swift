//
//  CalculatorBrain.swift
//  Calculator01
//
//  Created by maisapride8 on 03/06/16.
//  Copyright © 2016 maisapride8. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    
    private var internalProgram =  [AnyObject]()
    
    func setOperand(operand: Double)
    {
        accumulator = operand
        internalProgram.append(operand)
        descriptionAccumulator = String(format: "%g", operand)
    }
    
    
    var description: String {
        get {
            if pending == nil{
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    
    var isPartialResult: Bool {
        get{
            return pending != nil
        }
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt,{"√(" + $0 + ")" }),
        "x²": Operation.UnaryOperation({ pow($0, 2)}, {"(" + $0 + ")²"}),
        "x³": Operation.UnaryOperation({ pow($0, 3)}, {"(" + $0 + ")³"}),
        "x⁻¹": Operation.UnaryOperation({ 1 / $0 }, {"(" + $0 + ")⁻¹"}),
        "cos": Operation.UnaryOperation(cos,{"cos(" + $0 + ")"}),
        "sin": Operation.UnaryOperation(sin,{"sin(" + $0 + ")"}),
        "tan": Operation.UnaryOperation(tan,{"tan(" + $0 + ")"}),
        "sinh": Operation.UnaryOperation(sinh,{"sinh(" + $0 + ")"}),
        "cosh": Operation.UnaryOperation(cosh, {"cosh(" + $0 + ")"}),
        "tanh": Operation.UnaryOperation(tanh, {"tanh(" + $0 + ")"}),
        "log": Operation.UnaryOperation(log10, {"log(" + $0 + ")"}),
        "±" : Operation.UnaryOperation({-$0 }, {"-(" + $0 + ")"}),
        "×" : Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOperation(+, { $0 + " + " + $1 }, 0),
        "−" : Operation.BinaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ": Operation.BinaryOperation(pow, { $0 + " ∧ " + $1}, 2),
        "=" : Operation.Equals,
        "rand": Operation.NullaryOperation(drand48, "rand()")
      
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String, String) -> String, Int)
        case Equals
        case NullaryOperation(() -> Double, String)
    }
    
    
    private var currentPrecedence = Int.max
    
    func performOperation(symbol: String)
    {
        internalProgram.append(symbol)
        if let operation = operations[symbol]
        {
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case.BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(BinaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                
            case .Equals:
                executePendingBinaryOperation()
            case.NullaryOperation(let function, let descriptionValue): accumulator = function()
                            descriptionAccumulator = descriptionValue
            }
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.BinaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    var pending: PendingBinaryOperationInfo?
    struct PendingBinaryOperationInfo {
        var BinaryFunction: (Double, Double)-> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    typealias propertylist = AnyObject
    var program: propertylist{
        get{
            
            return internalProgram
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear()
    {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    var result: Double{
        get{
            return accumulator
        }
    }
    
    
    
}
