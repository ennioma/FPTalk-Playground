struct SomeData {
    var currentData: Date
}

// ---------------------------------------------------------------------------
func tellMeTheTruth(someData: SomeData) -> Bool {
    if someData.currentData > Date() {
        return true
    }

    return false
}

func tellMeTheTruth(someData: SomeData, compareDate: Date) -> Bool {
    if someData.currentData > compareDate {
        return true
    }

    return false
}
// ---------------------------------------------------------------------------

import Foundation

precedencegroup FunctionComposition {
    associativity: left
}

infix operator ⏭: FunctionComposition

func ⏭<A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { input in
        return g(f(input))
    }
}
//
func triple(a: Int) -> Int { return a * 3 }
func square(a: Int) -> Int { return a * a }

(triple ⏭ square)(2)

func convert(a: Int) -> String { return String.init(a) }

(triple ⏭ square ⏭ convert)(2)

enum Result<T> {
    case success(T)
    case failure(NSError)
}

extension Result {
    func bind<U>(f: ((T) -> Result<U>)) -> Result<U> {
        switch self {
        case let .success(value):
            return f(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result: Equatable {
    static func ==(lhs: Result<T>, rhs: Result<T>) -> Bool {
        switch (lhs, rhs) {
            case (.success, .success), (.failure, .failure): return true
            default: return false
        }
    }
}
//
func evaluateMyString(inputString: String) -> Result<String> {
    print("1 evaluateMyString")
    if inputString.count % 2 == 0 {
        return Result.success(inputString)
    } else {
        return Result.failure(NSError(domain: "aDomain", code: 1, userInfo: nil))
    }
}

func doSomethingWithThatString(inputString: String) -> Result<Bool> {
    print("2 doSomethingWithThatString")
    if inputString == "Snow" { return Result.success(true) }

    return Result.failure(NSError(domain: "aDomain", code: 2, userInfo: nil))
}

func generalFunction(inputString: String) -> Result<Bool> {
    return evaluateMyString(inputString: inputString).bind { doSomethingWithThatString(inputString: $0)}
}

import XCTest
XCTAssertEqual(evaluateMyString(inputString: "OddString"), Result.failure(NSError(domain: "aDomain", code: 1, userInfo: nil)))
XCTAssertEqual(evaluateMyString(inputString: "EvenString"), Result.success("EvenString"))
XCTAssertEqual(doSomethingWithThatString(inputString: "NotSnow"), Result.failure(NSError(domain: "aDomain", code: 2, userInfo: nil)))
XCTAssertEqual(doSomethingWithThatString(inputString: "Snow"), Result.success(true))

let evaluation = generalFunction(inputString: "Masi")

switch evaluation {
case let .success(value):
    print("🎉 \(value)")
case let .failure(error):
    print("👎🏼 \(error)")
}
