import Foundation

// Use change of base formula to compute log with any base
func logWithBase(x: Double, base: Double) -> Double {
    return log(x) / log(base)
}


logWithBase(x: 9.0, base: 3.0)


func computeProb(for firstSampleCount: Double, with secondSampleCount: Double) -> Double {
    return firstSampleCount / (firstSampleCount + secondSampleCount)
}


// x = true, o = false
let dataset1 = [true,true,true,true,true,true, false]

let dataset2 = [true,true,false,false,false]

extension Array where Element == Bool {
    func computeEntropy() -> Double {
        let trues = self.filter({$0 == true})
        let falses = self.filter({$0 == false})
        
        let pa = Double(trues.count) / Double(self.count)
        let pb = Double(falses.count) / Double(self.count)
        
        return (-pa*log2(Double(pa))) - (pb*log2(Double(pb)))
    }
}

let h1 = dataset1.computeEntropy()
let h2 = dataset2.computeEntropy()

h1 < h2 // => h2 less pure than h1



enum ballColor: String, CaseIterable {
    case red = "red"
    case blue = "blue"
}

struct ball {
    var color: ballColor
    var probability: Double = 0.0
    var entropy: Double = 0.0
    
    init(color: ballColor) {
        self.color = color
    }
    
    init(color: ballColor, prob: Double) {
        self.color = color
        self.probability = prob
    }
    
    // Maybe refactor init above?
    mutating func setEntropy(for value: Double) {
            self.entropy = value
    }
}

// Ideally we would want to make this more generic...
// We could make a Protocol that would enforce some of the constraints that would allow
// for a type safe way to compute entroy on a generic collection of things
// IDEA: protocol Entroyable? (thats a gross name 😅)
extension Array where Element == ball {
    // setProbability ... currently contains 2 for loops. Maybe thinking more about this we could optimize this?
    func setProbability() -> [ball] {
        var redCount = 0.0
        var blueCount = 0.0
        for item in self {
            switch item.color {
            case .red:
                redCount += 1.0
            case .blue:
                blueCount += 1.0
            }
        }
        
        let redProb = redCount / Double(self.count)
        let blueProb = blueCount / Double(self.count)
        
        // THis would be a runtime error?
        assert((redProb + blueProb) == 1.0)
        
        var newBucket = [ball]()
        
        for item in self{
            switch item.color {
            case .red:
                newBucket.append(ball(color: item.color, prob: redProb))
            case .blue:
                newBucket.append(ball(color: item.color, prob: blueProb))
                
            }
        }
        
        return newBucket
    }
    
    // TODO: Think more about a better name for this function
    func computeWinProbability() -> Double {
        let newBucket = setProbability()
        return newBucket.reduce(1.0, {$0 * $1.probability})
    }
    
    func computeProbability(for color: ballColor) -> Double {
        let colorCount = self.filter({$0.color == color}).count
        return Double(colorCount) / Double(self.count)
    }
    
    func entropy() -> Double {
        let reds = self.filter({$0.color == .red})
        let blues = self.filter({$0.color == .blue})
        
        let pRed = Double(reds.count) / Double(self.count)
        let pBlue = Double(blues.count) / Double(self.count)
        
        let e = (-pRed*log2(Double(pRed))) - (pBlue*log2(Double(pBlue)))
        if e.isNaN {
            return 0.0
        } else {
            return e
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////

let bucket1 = [ball(color: .red), ball(color: .red), ball(color: .red), ball(color: .red)]
let bucket1WinProbability = bucket1.computeWinProbability()
let bucket2 = [ball(color: .red), ball(color: .red), ball(color: .red), ball(color: .blue)]
let bucket2WinProbability = bucket2.computeWinProbability()
let bucket3 = [ball(color: .red), ball(color: .red), ball(color: .blue), ball(color: .blue)]
let bucket3WinProbability = bucket3.computeWinProbability()

////////////////////////////////////////////////////////////////////////////////////////
let bucket1RedWinProbability = bucket1.computeProbability(for: .red)
let bucket1BlueWinProbability = bucket2.computeProbability(for: .blue)
////////////////////////////////////////////////////////////////////////////////////////
let bucket2RedWinProbability = bucket2.computeProbability(for: .red)
let bucket2BlueWinProbability = bucket2.computeProbability(for: .blue)
////////////////////////////////////////////////////////////////////////////////////////
let bucket3RedWinProbability = bucket3.computeProbability(for: .red)
let bucket3BlueWinProbability = bucket3.computeProbability(for: .blue)
////////////////////////////////////////////////////////////////////////////////////////


bucket1.entropy()
bucket2.entropy()
bucket3.entropy()


let anotherBucket = [
    ball(color: .red),
    ball(color: .red),
    ball(color: .red),
    ball(color: .red),
    ball(color: .red),
    ball(color: .blue),
    ball(color: .blue),
    ball(color: .blue),
]

anotherBucket.entropy()

/*
    NOTE:
    To this point we have only considered "datasets" with 2 clases.
    At a language level we also only know how to compute entropy for Arrays that contain the ball type.
    Ideally we would want something more generic
*/
