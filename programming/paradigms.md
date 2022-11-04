# Paradigms

Programming paradigms are just ways to classify and describe how a language can be used, or is intended to be used.
Almost all languages fall under multiple paradigms, but typically one will be dominant over the others. There are
generally two type of programming paradigms that other fall under:

1. Imperative uses statements and expressions to change the program state, and describes how a program will operate
2. Declarative describes the results of the program, and focuses more on what you want to do rather than how

The line between imperative and declarative languages can sometimes be blurred depending on what you are writing with
your code. When writing a library you code will almost always take on a more imperative feel, whether the langauge
you are using is imperative or declarative. The inverse of this is also true. When using libraries, your code can start
to feel more declarative depending on how much logic you need to use beside that which is provided by the library.

## Procedural

Procedural programming is probably the simplest and most naturally understood paradigm. In a lot of ways procedural
languages are composed of a list of steps to take to complete a task. The functions and data you pass to those functions
are completely separate concepts. Most languages are at least in part procedural (it would be hard for a language to not
be in some way procedural), but purely procedural languages are not super common.

By far the most famous purely procedural language is C. If you have any experience with C you should be able to
understand why its procedural. It's just a collection of functions and structs that you pass to those functions.

```c
#include <stdio.h>

struct Hobbit
{
    char *name;
    int age;
};

void display_hobbit(struct Hobbit *hobbits)
{
    printf("Hobbit %s is %d years old", hobbit->name, hobbit->age);
}

int main()
{
    struct Hobbit hobbit;
    hobbit.name = "Bilbo Baggins";
    hobbit.age = 111;

    display_hobbit(&hobbit);
}
```

You can see that the `Hobbit` data and the `display_hobbit` function to display that data are defined separately, and
the only things tying them together are the function parameters and their names. The program entrypoint `main` reads
like a list of data types, and a list of things to do to that data.

Even though the `Hobbit` type and `display_hobbit` function does resemble something you might see in an object-oriented
language, C structs are strictly used for data storage. A C struct can't "do anything," its the `display_hobbit` that
does the displaying. Due to this "function does all the work" style, procedural programming is a little funky since it
can fluctuate between imperative and declarative much more than some other paradigms. Depending on how much you rely on
functions to operate on your data, procedural code can have a real declarative feel.

One big downside of procedural code, is that all data is visible to the user. If you write a struct that has data that
should never be manually accessed or mutated by the user, it is next to impossible to keep them from doing that.
All you can do is yell and scream at them until they pretend to do as you say. For example:

```c
struct Example
{
    int independent; // do not set this field directly, call set_independent instead
    int dependent;   // this field will change in response to mutating the independent field
};

void set_independent(struct Example *example, int value)
{
    example->independent = value;
    example->dependent = value * 2;
}

int main()
{
    struct Example example;

    set_independent(&example, 10);

    example.independent = 5;
    example.dependent = 11;
}
```

It should be pretty clear how potentially dangerous it can be for all the data to be exposed for user modification.
After calling `set_independent` both fields in `Example` are what they are expected to be. But after setting both fields
directly, we can no longer safely assume that `independent` and `dependent` will be correctly correlated. This type of
functionality is simple in paradigms like object-oriented programming (OOP) where data hiding and encapsulation are core
principles and goals of the language.

Ofcourse we could mitigate this by appending "private" fields with an `_` to indicate that is private, but this is just
a convention and will not provide any real safety.

In part because the data in procedural code has very little overhead, procedural languages tend to use memory very
efficiently.

## Object-Oriented

Object-oriented code is very similar to procedural code except that the functions to operate on data are bound much more
closely to that data. When functions are added to the data, that data becomes known as an object and are defined with
classes. Many modern languages adopt this concept to varying degrees. For example, both C++ and Python provide the
ability to create classes on top of their procedural aspects, whereas a langauge like java (and everything else built to
work with the JVM) is as purely object-oriented as you will find (at least under the hood for things like scala).

To see just how object-oriented java is as compared to languages like C++ or python lets look at these equivalent
programs:

```java
class HelloWorld {
    public static void main(String args[]) {
        System.out.println("Hello, World");
    }
}
```

```c++
#include <iostream>
using namespace std;

int main() {
   cout << "Hello, World!" << endl; // This prints Hello, World!
   return 0;
}
```

```python
print("Hello, World!")
```

Now lets play a game of Count the Classes!

| langauge | classes               |
|----------|-----------------------|
| java     | `HelloWorld` `System` |
| c++      | `cout`                |
| python   |                       |

In our purely object-oriented langauge we have to either create or reference 2 classes just to print something to
`stdout`, where c++ we only need one, and in python we don't need any, even though classes exist for all of those
languages. You can see that Java uses classes for just about everything. Even where we don't initialize any objects of a
class, we still reference a method of a class.

This perfectly embodies the concepts of object-oriented programming! Behavior is associated with an object, that object
is created, and we execute that behavior by referencing that object. When structuring your code your first steps are to
identify the expected behavior, split that behavior into components, and define classes that reflect those components.
As a result object-oriented code can be very organized and therefore very readable; however, if poorly utilized
object-oriented can be as unmaintainable as the next paradigm.

On the downside, because of all this object initialization object-oriented code can also be fairly greedy when it comes
to memory and CPU cycles.

In languages where object-oriented design is very prevalent, they will almost always be imperative as well. This is
because any code will involve initializing objects and calling methods on those objects. It would be difficult and
confusing to write a Java program that is largely driven by methods operating on data.

Now lets show off the data hiding we talked about in [procedural programming](#procedural):

```java
package main;

class Main {
    static class Example {
        private int independent;
        private int dependent;

        public void setIndependent(int value) {
            this.independent = value;
            this.dependent = this.independent * 2;
        }

        public int getIndependent() {
            return this.independent;
        }

        public int getDependent() {
            return this.dependent;
        }
    }

    public static void main(String args[]) {
        Example example = new Example();

        example.setIndependent(10);

        System.out.println("Independent: " + example.getIndependent());
        System.out.println("Dependent: " + example.getDependent());
    }
}
```

You can see that unlike in the procedural example, we are able to fully control access to both the `independent` and
`dependent` values of our `Example` class because we can control visibility. Unfortunately not all object systems allow
for this. For example, in python visibility isn't really addressed other than a convention of adding `_` to indicate
protected and `__` to indicate private fields, but those fields are still accessible just technically "hidden" and
potentially stored differently in the class `__dict__`.

## Functional

As you might expect, the basis of functional programing is functions. Functional programming typically excels when it
comes to processing data. One of the hallmarks of a functional language is that functions are "first class citizens."
This means that you can treat functions the same way you would treat any other value like an integer or a string.

While not always the case, some functional languages work hard to enforce "pure functions," which means functions that
have no external side effects. One common characteristic of this is copying all values passed to a function, which
forces a function to modify and return the copied parameter to avoid causing changes to a value outside the scope of the
function. Pure functions should also **always** return the same value for the same inputs because they will not rely on
any external data to determine the return value.

Another common characteristic of functional languages is iteration through recursion. While recursion can often be
expensive as compared to typical iteration via looping, iteration through recursion is often optimized using tail
recursion (and some compiler optimizations) which helps to mitigate the stack usage.

Due to the declarative nature of functional programming, its is usually quiet easy to understand what it does. Take
these javascript snippets for example:

```javascript
// procedural
const numList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
let result = 0;
for (let i = 0; i < numList.length; i++) {
    if (numList[i] % 2 === 0) {
        result += numList[i] * 10;
    }
}

// functional
const result = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    .filter(n => n % 2 === 0)
    .map(a => a * 10)
    .reduce((a, b) => a + b);
```

While the functional example does require you to understand what `filter`, `map` and `reduce` do, it will also take most
readers less time to understand what it does as opposed to the first example. Because of this nice readability, many
languages have either designed some support for functional programming or has added it over time.
