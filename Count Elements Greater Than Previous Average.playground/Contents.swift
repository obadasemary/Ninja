import Foundation

class Solution {
    func sum(_ num1: Int, _ num2: Int) -> Int {
        return num1 + num2
    }
    
    func countResponseTimeRegressions(responseTimes: [Int]) -> Int {
        // Write your code here
        guard responseTimes.count > 1 else {
            return 0
        }
        
        var count = 0
        let sortedResponseTimes = responseTimes.sorted()
        var sum = sortedResponseTimes[0]
        
        for i in 1..<sortedResponseTimes.count {
            
            let avg = Double(sum) / Double(i)
            
            if Double(sortedResponseTimes[i]) > avg {
                count += 1
            }
            
            sum += sortedResponseTimes[i]
        }
        
        return count
    }
    
    func generateResponseTimes() -> [Int] {
        guard let responseTimesCount = Int((readLine()?.trimmingCharacters(in: .whitespacesAndNewlines))!)
        else { fatalError("Bad input") }

        var responseTimes = [Int]()

        for _ in 0..<responseTimesCount {
            guard let responseTimesItem = Int((readLine()?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            else { fatalError("Bad input") }

            responseTimes.append(responseTimesItem)
        }

        return responseTimes
    }
    
    // Playground-friendly version for testing
    func generateResponseTimesFromInput(_ input: [String]) -> [Int] {
        var inputIndex = 0
        
        guard inputIndex < input.count,
              let responseTimesCount = Int(input[inputIndex].trimmingCharacters(in: .whitespacesAndNewlines))
        else { fatalError("Bad input") }
        
        inputIndex += 1
        var responseTimes = [Int]()

        for _ in 0..<responseTimesCount {
            guard inputIndex < input.count,
                  let responseTimesItem = Int(input[inputIndex].trimmingCharacters(in: .whitespacesAndNewlines))
            else { fatalError("Bad input") }

            responseTimes.append(responseTimesItem)
            inputIndex += 1
        }

        return responseTimes
    }
}

let solution = Solution()
print(solution.sum(12, 5))

print(solution.sum(-10, 4))

print(solution.countResponseTimeRegressions(responseTimes: [100, 200, 150, 300]))

print(solution.countResponseTimeRegressions(responseTimes: [0, 100, 300, 200]))

print(solution.countResponseTimeRegressions(responseTimes: [600, 100, 300, 200]))

print(solution.countResponseTimeRegressions(responseTimes: [0]))

// Test cases based on the problem description
print("=== Test Cases ===")

// Sample Input 0: n = 0
let testInput0 = ["0"]
let parsedResponseTimes0 = solution.generateResponseTimesFromInput(testInput0)
let result0 = solution.countResponseTimeRegressions(responseTimes: parsedResponseTimes0)
print("Sample Input 0 - Array: \(parsedResponseTimes0), Result: \(result0)")

// Sample Input 1: n = 1, element = 100
let testInput1 = ["1", "100"]
let parsedResponseTimes1 = solution.generateResponseTimesFromInput(testInput1)
let result1 = solution.countResponseTimeRegressions(responseTimes: parsedResponseTimes1)
print("Sample Input 1 - Array: \(parsedResponseTimes1), Result: \(result1)")

// Example from problem description: n = 4, elements = [100, 200, 150, 300]
let testInput2 = ["4", "100", "200", "150", "300"]
let parsedResponseTimes2 = solution.generateResponseTimesFromInput(testInput2)
let result2 = solution.countResponseTimeRegressions(responseTimes: parsedResponseTimes2)
print("Example Input - Array: \(parsedResponseTimes2), Result: \(result2)")

// Note: To use with actual input in a command-line program:
// let reponseTimes = solution.generateResponseTimes()
// let result = solution.countResponseTimeRegressions(responseTimes: reponseTimes)
// print(result)
