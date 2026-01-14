import Foundation

var greeting = "Hello, playground"

struct StructClassActorBootcamp {
    
    func start() {
        runTest()
    }
}

let x = StructClassActorBootcamp()
x.start()

struct MyStruct {
    var text: String
}

class MyClass {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    func updateText(to newText: String) {
        self.text = newText
    }
}

private extension StructClassActorBootcamp {
    
    func runTest() {
//        structTest1()
//        printDivider()
//        classTest1()
//        printDivider()
        structTest2()
        printDivider()
        classTest2()
    }
    
    func printDivider() {
        print("""
            
            -----------------------------------
            
            """)
    }
    
    func structTest1() {
        print("structTest1 started! \n")
        let objectA = MyStruct(text: "strating title!")
        print("Object A: \(objectA.text)")
        
        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA
        print("Object B: \(objectB.text)")
        
        objectB.text = "changed title!"
        print("Object B: title changed")
        
        print("Object A: \(objectA.text)")
        print("Object B: \(objectB.text)")
    }
    
    func classTest1() {
        print("classTest1 started! \n")
        let objectA = MyClass(text: "strating title!")
        print("Object A: \(objectA.text)")
        
        print("Pass the REFERENCES of objectA to objectB")
        let objectB = objectA
        print("Object B: \(objectB.text)")
        
        objectB.text = "changed title!"
        print("Object B: title changed")
        
        print("Object A: \(objectA.text)")
        print("Object B: \(objectB.text)")
    }
}

struct CustomStruct {
    let text: String
    
    func updateText(to newText: String) -> CustomStruct {
        CustomStruct(text: newText)
    }
}

struct MutatingStruct {
    private(set) var text: String
    
    init(text: String) {
        self.text = text
    }
    
    mutating func updateText(to newText: String) {
        self.text = newText
    }
}

private extension StructClassActorBootcamp {
    
    func structTest2() {
        print("structTest 2 !\n")
        
        var struct1 = MyStruct(text: "Title 1")
        print("Struct 1: ", struct1.text)
        struct1.text = "Title 2"
        print("Struct 1: ", struct1.text)
        
        var struct2 = CustomStruct(text: "Title 1")
        print("Struct 2: ", struct2.text)
        
        struct2 = CustomStruct(text: "Title 2")
        print("Struct 2: ", struct2.text)
        
        var struct3 = CustomStruct(text: "Title 1")
        print("Struct 3: ", struct3.text)
        struct3 = struct3.updateText(to: "Title 2")
        print("Struct 3: ", struct3.text)
        
        var struct4 = MutatingStruct(text: "Title 1")
        print("Struct 4: ", struct4.text)
        struct4.updateText(to: "Title 2")
        print("Struct 4: ", struct4.text)
    }
}

private extension StructClassActorBootcamp {
    
    func classTest2() {
        print("classTest 2 !\n")
        
        let class1 = MyClass(text: "Title 1")
        print("Class 1: ", class1.text)
        class1.text = "Title 2"
        print("Class 1: ", class1.text)
        
        let class2 = MyClass(text: "Title 1")
        print("Class 2: ", class2.text)
        class2.updateText(to: "Title 2")
        print("Class 2: ", class2.text)
        
        let class3 = class2
        print("Class 2: ", class2.text)
        print("Class 3: ", class3.text)
        class3.updateText(to: "Title 3")
        print("Class 2: ", class2.text)
        print("Class 3: ", class3.text)
    }
}
