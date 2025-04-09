function Person(name) {
    this.name = name;
}

// 在原型对象上添加方法
Person.prototype.sayHello = function() {
  console.log(`Hello, I'm ${this.name}`);
};

const alice = new Person("Alice");
alice.sayHello(); // 输出: Hello, I'm Alice


Person.prototype.age = 25;
console.log(alice.age); // 输出: 25

const bob = new Person("Bob");
console.log(bob.age); // 输出: 25


//原型对象的 constructor 属性指向构造函数本身。
console.log(Person.prototype.constructor === Person); // 输出: true
console.log(alice.constructor === Person); // 输出: true（通过原型链查找）

//继承
// 父类
function Animal(name) {
    this.name = name;
}
Animal.prototype.eat = function() {
    console.log(`${this.name} is eating.`);
};

// 子类
function Dog(name, breed) {
    Animal.call(this, name); // 继承属性
    this.breed = breed;
}

// 继承方法：设置 Dog.prototype 的原型为 Animal.prototype
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog; // 修复 constructor 指向

Dog.prototype.bark = function() {
    console.log("Woof!");
};

const myDog = new Dog("Buddy", "Golden Retriever");
myDog.eat(); // 输出: Buddy is eating.
myDog.bark(); // 输出: Woof!