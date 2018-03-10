import Foundation

typealias CurryFunction<A, B, C> = (A, B) -> C
typealias CurryOutputFunction<A, B, C> = (A) -> ((B) -> C)

func curry<A, B, C>(f: @escaping CurryFunction<A, B, C>) -> CurryOutputFunction<A, B, C> {
    return { a in { b in f(a, b) } }
}

func sum(a: Int, b: Int) -> Int { return a + b }

let curriedFunction = curry(f: sum)
let curriedFunctionOneParam = curriedFunction(3)
let finalValue = curriedFunctionOneParam(4)

precedencegroup InjectOperator {
    associativity: left
}

precedencegroup FunctionComposition {
    associativity: left
    higherThan: InjectOperator
}

infix operator ⏭: FunctionComposition

func ⏭<A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { input in
        return g(f(input))
    }
}

func triple(a: Int) -> Int {
    print("tripling \(a)")
    return a * 3
}
func square(a: Int) -> Int {
    print("squaring \(a)")
    return a * a
}

(triple ⏭ square)(2)

infix operator ⤵️: InjectOperator
func ⤵️<T, U>(value: T, f: (T) -> U) -> U {
    return f(value)
}

let value = 2 ⤵️ triple ⏭ square

func convert(a: Int) -> String {
    print("converting \(a)")
    return String.init(a)
}

(triple ⏭ square ⏭ convert)(3)

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

