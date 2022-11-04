# Programming Principles

## KISS

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

## DRY

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

## SOLID

Solid is probably the most comprehensive principle but is targeted more towards Object Oriented Programming, and
describes multiple topics that are themselves principles.

### Single Responsibility Principle

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

### Open / Closed Principle

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

### Liskov's Substitution Principle

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

### Interface Segregation Principle

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

### Dependency Inversion Principle

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
