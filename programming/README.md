# Programming

If you've made your way here you probably already know what programming is.

This directory will cover the more general concepts, topics, and best practices of programming rather than covering any
specific languages.

## Main Programming Principles

### KISS

Keep It Simple Stupid (KISS) is simply telling you to write programs as simply as possible. While fancy code might be
cool and more fun to brag about to your rubber ducky, unless it provides a real performance increase in a place where
performance matters, simple is better. Take the following code blocks for example:

```python
def equal(left: int, right: int) -> bool:
    while left != 0 and right != 0:
        left -= 1
        right -= 1

    return left == 0 and right == 0
```

While the above code does work, without the function name it would not be immediately apparent what it was supposed to
do. Even looking at the code it isn't super clear *how* the method is testing for equality. Now lets look at an example
that's almost so simple it's stupid:

```python
def equal(left: int, right: int) -> bool:
    return left == right
```

Even if the function above was named `doSomethingSimply` it would be immediately obvious what the function is trying to
do just by reading the code. In this example, the simpler code is also a lot more efficient than the complicated code,
but that isn't always the case.

### DRY

Do not Repeat Yourself (DRY) is the principle tht code should never or at least very rarely be repeated. If you find
yourself manually typing the same code over and over you should probably write a generic method to do that code for you
and just call it. This will drastically reduce the threat of typos (by far my greatest downfall) and maintain more
consistency in your code base. In general, a decent rule of thumb is two similar blocks can be fine, but three should
indicate that its time to write a method (even just a utility).

One of the driving ideas behind DRY is that it leads to greater maintainability. If a bug is found in a repeated block
of code, instead of having to find / remember each instance of that block, properly DRYed cod  would allow you to modify
that one block and call it a day. This will also help to break up long lines of code into more digestible chunks leading
to greater code readability. If it helps to drive the point home, non-DRYed code is moist and that just sounds wrong.

Let's look at an example:

```python
import requests
import typing

def get_user_fellowship_role(name: str) -> typing.Optional[str]:
    if name == "frodo":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/frodo")
        role = response.json()["role"]
    elif name == "samwise":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/samwise")
        role = response.json()["role"]
    elif name == "peregrin":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/peregrin")
        role = response.json()["role"]
    elif name == "meriadoc":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/meriadoc")
        role = response.json()["role"]
    elif name == "gandalf":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/gandalf")
        role = response.json()["role"]
    elif name == "legolas":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/legolas")
        role = response.json()["role"]
    elif name == "gimli":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/gimli")
        role = response.json()["role"]
    elif name == "aragorn":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/aragorn")
        role = response.json()["role"]
    elif name == "boromir":
        response = requests.get(url="https://api.lotr.com/fellowhip/roles/boromir")
        role = response.json()["role"]
    else:
        role = None

    return role
```

Boy howdy thats a lot of typing. It should be clear from the code above that the same two lines that fetch the user's
role depending on their name is repeated. The most obvious place you could trim down is on the url generation. So first
we'll probably want to pull that logic into its own method:

```python
def get_user_fellowship_role_endpoint(name: str) -> str:
    return f"https://api.lotr.com/roles/{name}"
```

Now what about the actual request handling? We don't necessarily need to separate that logic into its owm method
(although you could and should), so for now we'll use the conditional chain to store the endpoint url and move the
repeated request code to the bottom of the function:

```python
import requests
import typing

def get_user_fellowship_role_endpoint(name: str) -> str:
    return f"https://api.lotr.com/fellowship/roles/{name}"

def get_user_fellowship_role(name: str) -> typing.Optional[str]:
    if name == "frodo":
        role_endpoint = get_user_fellowship_role_endpoint("frodo")
    elif name == "samwise":
        role_endpoint = get_user_fellowship_role_endpoint("samwise")
    elif name == "peregrin":
        role_endpoint = get_user_fellowship_role_endpoint("peregrin")
    elif name == "meriadoc":
        role_endpoint = get_user_fellowship_role_endpoint("meriadoc")
    elif name == "gandalf":
        role_endpoint = get_user_fellowship_role_endpoint("gandalf")
    elif name == "legolas":
        role_endpoint = get_user_fellowship_role_endpoint("legolas")
    elif name == "gimli":
        role_endpoint = get_user_fellowship_role_endpoint("gimli")
    elif name == "aragorn":
        role_endpoint = get_user_fellowship_role_endpoint("aragorn")
    elif name == "boromir":
        role_endpoint = get_user_fellowship_role_endpoint("boromir")
    else:
        return None

    response = requests.get(url=role_endpoint)
    role = response.json()["role"]

    return role
```

Now what about all of those nasty repeated conditionals? We can combine them into one smaller lad and save ourselves
some typing:

```python
import requests
import typing

def get_user_fellowship_role_endpoint(name: str) -> str:
    return f"https://api.lotr.com/fellowship/roles/{name}"

def get_user_fellowship_role(name: str) -> typing.Optional[str]:
    if name not in ["frodo", "samwise", "peregrin", "meridaoc", "gandalf", "legolas", "gimli", "aragorn", "boromir"]:
        return None

    role_endpoint = get_user_fellowship_role_endpoint(name)
    response = requests.get(url=role_endpoint)
    role = response.json()["role"]

    return role
```

Look our DRYed code is starting to be even shorter than our moist code even just by accident! Now as it is, our code
looks pretty DRY, block of code is really quite unique. But what if somewhere else we try to get a user's role at
bilbo's party? We would write a function like this:

```python
import requests
import typing

def get_user_party_role_endpoint(name: str) -> str:
    return f"https://api.lotr.com/bilbo-party/{name}"

def get_user_party_role(name: str) -> typing.Optional[str]:
    # this is just a subsection of those at his party but boy howdy would that be a lot of typing and research
    if name not in ["bilbo", "gandalf", "frodo"]:
        return None

    role_endpoint = get_user_party_role_endpoint(name)
    response = requests.get(url=role_endpoint)
    role = response.json()["role"]

    return role
```

Shoot now our code is moist, but we can still use DRY to fix that. First, you should notice that both
`get_user_party_role` and `get_user_followship_role` are extremely similar. The only differences between those two
functions are the name and members of the target group. First lets focus on writing a more generic endpoint factory
method:

```python
def get_user_role_endpoint(group: str, name: str) -> str:
    return f"https://api.lotr.com/{group}/{name}"
```

Next we re-write our write a more generic user role accessor:

```python
import requests
import typing

def get_user_role_endpoint(group: str, name: str) -> str:
    return f"https://api.lotr.com/{group}/{name}"

def get_user_role(name: str, group: str, members: list[str]) -> typing.Optional[str]:
    if name not in members:
        return None

    role_endpoint = get_user_role_endpoint(group, name)
    response = requests.get(url=role_endpoint)
    role = response.json()

    return role
```

Now our code is DRY and we can access the roles of a member of the Fellowship of the Ring with
`get_user_role("frodo", "fellowship", ["frodo", "samwise", ...])`. You should now be able to see how properly DRYed code
is not just DRY for the current state of the codebase, but for future additions to it as well.

One thing that is neat about properly DRY code, is that it often satisfies many of the SOLID principles (if very
indirectly).

### SOLID

Solid is probably the most comprehensive principle but is targeted more towards Object Oriented Programming, and
describes multiple topics that are themselves principles.

#### Single Responsibility Principle

Code components should only be responsible for a single task. If you ever find yourself needing to explain a class,
method, etc using the word "and" you can almost certainly refactor that code to be two components. Take the following
code for example:

```python
class Bow:
    def __init__(self):
        self.arrows = 10

        self.pull_weight = 10
        self.durability = 10


    def shoot(self):
        """Shot the bow, decreasing the durability by 1."""
        if self.durability == 0:
            raise ValueError("Bow is broken")

        self.durability -= 1

    def take_arrow(self) -> int:
        """Retrieve an arrow from the quiver and return how many arrows are left."""
        if self.arrows == 0:
            raise ValueError("Quiver is empty")

        self.arrows -= 1
        return self.arrows

    def shoot_bow(self) -> bool:
        """Attempt to shoot the Archer's bow"""
        try:
            self.take_arrow()
        except ValueError:
            return False

        try:
            self.shoot()
        except ValueError:
            return False

        return True
```

The code above is not just acting as a bow, but as an `Archer` and `Quiver` as well. It's managing both the state of the
bow, the state of the quiver, and the logic surrounding shooting the bow. To satisfy this principle, we'll need to add
some classes:

```python
class Bow:
    def __init__(self):
        """Bow is basically just a dataclass."""
        self.pull_weight = 10
        self.durability = 10

    def shoot(self):
        """Shot the bow, decreasing the durability by 1."""
        if self.durability == 0:
            raise ValueError("Bow is broken")

        self.durability -= 1

class Quiver:
    def __init__(self):
        """Quiver is basically just a dataclass."""
        self.arrows = 10

    def take_arrow(self) -> int:
        """Retrieve an arrow from the quiver and return how many arrows are left."""
        if self.arrows == 0:
            raise ValueError("Quiver is empty")

        self.arrows -= 1
        return self.arrows

class Archer:
    def __init__(self):
        self.bow = Bow()
        self.quiver = Quiver()

    def shoot_bow(self) -> bool:
        """Attempt to shoot the Archer's bow"""
        try:
            self.quiver.take_arrow()
        except ValueError:
            return False

        try:
            self.bow.shoot()
        except ValueError:
            return False

        return True
```

In the code above each class has a single clear responsibility.

- `Bow`s store some basic stats and keep track of how many shots it can make before it breaks.
- `Quiver` simply keeps track of how many arrows are available to shoot.
- `Archer` managed a `Quiver` and `Bow`.

While the separated code does have more lines, it is much more clear to the user what each class is responsible for, and
avoids having one monolith tracking the state of multiple conceptual objects at once. After all its Legolas who is
pulling arrows from his quiver, and shooting them with the bow. The bow can't arm or shoot itself.It will also allow us
to have simpler and more target unit tests.

#### Open / Closed Principle

Code components should be "open for extension but closed for modification." This means that when or you want to add new
behavior to your code, you should not modfy existing components to perform that behavior, but inherit from the existing
components to implement the desired behavior. For example, lets pretend we're Sauron developing the lesser rings of
power:

```python
class LesserRingOfPower:
    """A simple parent class for a Lesser Ring of Power"""

    def obey_the_one_ring(self):
        """Do whatever the one rings instructs it to do"""
```

Obviously just giving a ring that allows you to control the bearer won't entice any elvin kings. So you need to *extend*
your parent `LesserRingOfPower` class to allow for something you can use to entice those pesky elven kings:

```python
import abc

class LesserRingOfPower(abc.ABC):
    """A simple parent class for a Lesser Ring of Power"""

    def obey_the_one_ring(self):
        """Do whatever the one rings instructs it to do"""

class Narya(LesserRingOfPower):
    def defend_thee_from_weariness(self):
        """Rekindle the hearts to the valor of old in a world that grows chill."""

class Nenya(LesserRingOfPower):
    def preserve(self):
        """Hold evil from the land."""

class Vilya(LesserRingOfPower):
    def do_something(self):
        """We don't really know what Vilya did."""
```

You can see in the example above that we were able to add more behavior to create mor Rings of Power, without having to
modify the existing `RingOfPower` class. This will make you code a lot more maintainable since additional features or
behavior will require very little modification of existing code, and more using existing cod to write new code.

#### Liskov's Substitution Principle

This principle simply states that any parent class should be "hot swappable" wih any child class without any behavior
modification. In essence, the same methods should behave similarly and should not have any different side effects. A
classic example of this is the `Rectange` and `Square` (sorry no lotr reference this time around):

```python
import abc

class Shape(abc.ABC):
    pass


class Rectangle(Shape):
    def __init__(self):
        self._height = 100
        self._width = 10

    def set_height(self, height):
        self._height = height

    def set_width(self, width):
        self._width = width


class Square:
    def __init__(self):
        self._height = 100
        self._width = 10

    def set_height(self, height):
        self._height = height
        self._width = height

    def set_width(self, width):
        self._width = width
        self._height = width
```

While it makes logical sense that the `Square` should inherit from `Rectangle`, using the implemented classes can be
confusing. When you call `Square.set_height` you are not just setting the height, but the width as well. Your extension
has caused there to be a difference in behavior between `Rectangle` and `Square` making the two not nearly as "hot
swappable" as you might've originally thought. Instead `Square` should be an independent entity:

```python
class Shape:
    pass

class Square(Shape):
    def __init__(self):
        self.size = 10

    def set_size(self , size):
        self.size = size
```

The `set_size` method, much more accurately describe the actual behavior of `Square`, while still allowing you to create
a logical square by manually setting the `height` and `width` of the `Rectanlge` to be equal.

#### Interface Segregation Principle

This principle will probably sound similar to Single Responsibility. Interface Segregation is simply the practice of
keeping interfaces as small and specific as possible. Take the below java interfaces for examples:

```python
import abc

class Elf(abc.ABC):
    def sing(self):
        pass

    def shoot_bow(self):
        pass

    def swing_sword(self):
        pass
```

It should be obvious that the methods in this interface can easily be extracted, which would make implementing an `Elf`
more clear about what the `Elf` can do that is specific to Elves. This extraction also allows you to re-use those same
interfaces for other races leading to more maintainability:

```python
import abc

class Singer(abc.ABC):
    @abc.abstractmethod
    def sing(self):
        pass

class Archer(abc.ABC):
    @abc.abstractmethod
    def shoot_bow(self):
        pass

class SwordFighter(abc.ABC):
    @abc.abstractmethod
    def swing_sword(self):
        pass

class Elf(Singer, Archer, SwordFighter):
    def sing(self):
        pass

    def shoot_bow(self):
        pass

    def swing_sword(self):
        pass

    def do_elf_things(self):
        pass
```

#### Dependency Inversion Principle

I find many of the descriptions I see on the internet for this principle to be pointlessly confusing. In short, top
level definitions should only rely on top level definitions, and never on concrete implementations. This is to avoid
tightly coupled types. See the example below:

```python
import abc

class Sword:
    def __init__(self):
        self.damage = 10
        self.durability = 10

    def use(self) -> int:
        if self.durability > 0:
            self.durability -= 1
            return self.damage

        return 0

class Warrior:
    @abc.abstractmethod
    def use_weapon(self, sword: Sword):
        """Use the given weapon."""
```

It should be pretty obvious that `Warrior` and `Sword` are tightly coupled together. This makes it annoying to add new
types of weapons and makes it more likely for changes to the `Sword` class to require changes to the `Warrior` class. To
increase the maintainability of we want to make a top level interface for the Sword:

```python
import abc

class Weapon(abc.ABC):
    @abc.abstractmethod
    def use(self) -> int:
        """Use the weapon and return the amount of damage it will do."""

class Sword(Weapon):
    def __init__(self):
        self._durability = 10
        self.damage = 10

    def use(self):
        if self._durability > 0:
            self._durability -= 1
            return self.damage

        return 0

class Warrior:
    @abc.abstractmethod
    def use_weapon(self, weapon: Weapon):
        """Use the given weapon."""
```

Now our `Sword` is seperated from our `Warrior` making it easier to add more `Weapon` implementations and ensure that
changes to `Sword` will not require changes to `Warrior`.

## Paradigms

Programming paradigms are just ways to classify and describe how a language can be used, or is intended to be used.
Almost all languages fall under multiple paradigms, but typically one will be dominant over the others. There are
generally two type of programming paradigms that other fall under:

1. Imperative uses statements and expressions to change the program state, and describes how a program will operate
2. Declarative describes the results of the program, and focuses more on what you want to do rather than how

The line between imperative and declarative languages can sometimes be blurred depending on what you are writing with
your code. When writing a library you code will almost always take on a more imperative feel, whether the langauge
you are using is imperative or declarative. The inverse of this is also true. When using libraries, your code can start
to feel more declarative depending on how much logic you need to use beside that which is provided by the library.

### Procedural

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

### Object-Oriented

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

### Functional

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

## Compiled vs Interpreted

### Compilation

There are two main ways code is read and translated by your computer. The first is compilation. Compilation is the
process of taking the human-readable code and converting it into something that your CPU can understand. This is usually
a multi-stage process consisting at least of Preprocessing, Compilation, Assembly, and Linking.

#### 1. Preprocessing

Preprocessing is the first step in compilation, and it prepares the code for the next phases. It'll expand macros, pull
in the contents of any dependency files, remove comments, etc. Preprocessed code should be fine as-is to pass to the
compiler.

#### 2. Compilation

Once the code is preprocessed, we need to start converting the code into something understandable by the computer. The
first step is to convert it into the lowest level of human-readable code called Assembly. The exact "dialect" assembly
depends on the specific CPU you are compiling your code for.

Initially I was confused as to why we even need this step. If the compiler already knows what architecture it needs to
produce machine code for, why not just jump straight to the machine code? The biggest bonus to this is that we can focus
one converting our text code to text assembly, and delegate the assembly to machine code conversion to the architecture
manufacturers who probably actually know what they're doing.

#### 3. Assembly

Assembly is the process of converting teh Assembly code from the previous step into something machine-readable or object
code.

#### 4. Linking

Linking is the final step which handles organizing the code so that the program can resolve all the symbols involved
during execution. There are two main linking strategies.

The first is static linking. This means that all necessary symbols are pulled into the final executable so that you will
not need to worry about installing any dependency libraries. As long as the executable works for your CPU, the
executable will run without any issues.

Alternatively, you could rely on dynamic linking. Dynamic linking effectively differs symbol resolution until runtime.
The main benefit of this linking strategy is that it allows your compiled binaries to be much smaller than statically
linked binaries. However, dynamically linked executables can cause "dependency hell" when you're missing the requisite
shared libraries or your library resolving system isn't properly configured. Dynamically linked code also takes a
performance hit since it has look for symbols at runtime rather than already knowing exactly where they will be.

### Interpreted

An interpreter has the same goal as a compiler: convert text code to machine code. The only difference is that an
interpreter does so at runtime rather. Where a compiler has to be run before you even run the code, and interpreter will
read the code and "interpret" the commands it finds to then send machine-code to the CPU.

Because you are in a sense compiling your code as you run it, there will always be a hit to performance for
interpretation as compared to compilation. On the other hand, since the interpreter is able to handle values as they
arrive, we can be much more relaxed with our typing systems. This is why interpreted languages like Python has such
dynamic typing systems, whereas C has to be very explicit with its types.

The biggest benefit of interpreted languages is that their code is platform independent. Where languages like C
sometimes needs to understand what type of machine it will be run on in order to make things work or provide
optimizations, an interpreter does all that for you so that the programmer can focus on the software rather than the
hardware. This will generally make interpreted languages a lot easier and faster to write.

Scripting languages (ex bash, python, etc) tend to be interpreted.

### Comparison

There is no true "best" between compiled and interpreted languages. As with all thing nuance exists, and what is best\
for you depends on what you are tyring to do.

| metric            | compiled vs interpreted | notes                                                                                     |
|-------------------|-------------------------|-------------------------------------------------------------------------------------------|
| execution speed   | compiled                |                                                                                           |
| development speed | interpreted             | this is only generally true not necessarily true of all interpreted vs compiled languages |
| portability       | interpreted             |                                                                                           |
| type safety       | compiled                |                                                                                           |

### WTF is Java

Now that I've gone on and one about interpreted and compiled languages, you might notice that Java doesn't seem to fit
cleanly into either category. You compile it with `javac` your source code into `.class` files, but it runs on a JVM?
The best answer is that Java is both!

You compile your `.java` files into the "bytecode" `.class` files, which are optimized for interpretation by the
interpreter. This approach is a good way to get a lot of the benefits of both options. You get the platform independence
of interpreted languages, but can also skip a lot of the steps that slow down interpretation speed. As a result Java is
a special child.

## Best Practices

### Input / Output (IO)

### Evil ^ .5

### Styling

#### Curly Braces

#### Tabs vs Spaces