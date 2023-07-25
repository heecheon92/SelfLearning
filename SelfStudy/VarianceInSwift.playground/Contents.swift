import Foundation

// Swift 스탠다드 라이브러리는 특수하게 Covariance를 지원한다.
// e.g
// Array<T>로 선언될 경우, T 또는 T의 Subtype 또한 T로 취급한다.

protocol Animal {}
struct Human: Animal {}
struct Cat: Animal {}
struct Dog: Animal {}

var animals: Array<Animal> = Array<Animal>()
animals.append(Human())
animals.append(Cat())
animals.append(Dog())

// 위와 같은 polymorphic behavior는 많은 OOP언어들이 지원하는
// 기능이지만 Swift의 스탠다드 라이브러리의 컨테이너 자료형이 특이 케이스인 이유는
// 개발자는 위의 covariant의 속성을 지는 자료형을 구현할 수 없기 때문이다.
// e.g.

struct Group<T> {
    var flock: Array<T>
}

let humanGroup  : Group<Human>      = Group<Human>(flock: [Human()])  // OK
let catGroup    : Group<Cat>        = Group<Cat>(flock: [Cat()])      // OK
let dogGroup    : Group<Dog>        = Group<Dog>(flock: [Dog()])      // OK
let animalGroup : Group<Animal>     = Group<Human>(flock: [Human()])  // Not OK
let animalGroupTwo: Group<Animal>   = Group<Animal>(flock: [Human()]) // OK

// 즉 위의 예시로 보았을때 스위프트의 Generic은 기본적으로 Invariance의 속성을 지닌다.
// 위와 같은 invariant한 동작 방식은 약간의 혼란을 가져올 수 있다.

func moveTogether(_ group: Group<Animal>) {}

// User-defined generic은 invariant 하므로 다음과 같이
// 호출 할 수 없다.
moveTogether(humanGroup)        // Not OK
moveTogether(catGroup)          // Not OK
moveTogether(dogGroup)          // Not OK
moveTogether(animalGroupTwo)    // OK

// 이러한 경우 함수 signature를 바꾸고 함수 오버로딩을 통해
// covariant처럼 동작하게 보이게 할 순 있다.

func moveTogetherGeneric(_ group: Group<Animal>) {}
func moveTogetherGeneric(_ group: Group<some Animal>) {}

moveTogetherGeneric(humanGroup)     // OK func moveTogetherGeneric(_ group: Group<some Animal>)
moveTogetherGeneric(catGroup)       // OK func moveTogetherGeneric(_ group: Group<some Animal>)
moveTogetherGeneric(dogGroup)       // OK func moveTogetherGeneric(_ group: Group<some Animal>)
moveTogetherGeneric(animalGroupTwo) // OK func moveTogetherGeneric(_ group: Group<Animal>)

// 번외로 이건 다른 함수를 일급객체로 취급하는 대부분의 언어와 마찬가지지만
// Swift의 함수 타입은 Contravariant하다.
// e.g.

var intHandler: ((Int) -> Void)? = { num in print(num * 2) }
var anyHandler: ((Any) -> Void)? = nil
anyHandler = intHandler   // Not OK


var _anyHandler: ((Any) -> Void)? = { something in print(something) }
var _intHandler: ((Int) -> Void)? = nil
_intHandler = _anyHandler   // But this is OK

// 언뜻 봤을땐 anyHandler = intHandler가 가능하고
// _intHandler = _anyHandler는 불가능해 보이지만
// 실상은 정반대다.
// 만약에 anyHandler = intHandler가 가능한 expression이라 가정해보자

//__> anyHandler = intHandler
//__> anyHandler("Hello, world")

// anyHandler의 시그니쳐는 Any를 받지만 실제 구현로직은 intHandler이고
// intHandler는 정수형을 받게 되어있으므로 구현 오류가 생긴다.

// 반대로
//__> _intHandler = anyHandler
//__> _intHandler("Hello, world") <- 타입 시그니쳐가 ((Int) -> Void)? 이므로 실행할 수 없다.


