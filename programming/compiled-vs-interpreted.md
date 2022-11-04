# Compiled vs Interpreted

## Compilation

There are two main ways code is read and translated by your computer. The first is compilation. Compilation is the
process of taking the human-readable code and converting it into something that your CPU can understand. This is usually
a multi-stage process consisting at least of Preprocessing, Compilation, Assembly, and Linking.

### 1. Preprocessing

Preprocessing is the first step in compilation, and it prepares the code for the next phases. It'll expand macros, pull
in the contents of any dependency files, remove comments, etc. Preprocessed code should be fine as-is to pass to the
compiler.

### 2. Compilation

Once the code is preprocessed, we need to start converting the code into something understandable by the computer. The
first step is to convert it into the lowest level of human-readable code called Assembly. The exact "dialect" assembly
depends on the specific CPU you are compiling your code for.

Initially I was confused as to why we even need this step. If the compiler already knows what architecture it needs to
produce machine code for, why not just jump straight to the machine code? The biggest bonus to this is that we can focus
one converting our text code to text assembly, and delegate the assembly to machine code conversion to the architecture
manufacturers who probably actually know what they're doing.

### 3. Assembly

Assembly is the process of converting teh Assembly code from the previous step into something machine-readable or object
code.

### 4. Linking

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

## Interpreted

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

## Comparison

There is no true "best" between compiled and interpreted languages. As with all thing nuance exists, and what is best\
for you depends on what you are tyring to do.

| metric            | compiled vs interpreted | notes                                                                                     |
|-------------------|-------------------------|-------------------------------------------------------------------------------------------|
| execution speed   | compiled                |                                                                                           |
| development speed | interpreted             | this is only generally true not necessarily true of all interpreted vs compiled languages |
| portability       | interpreted             |                                                                                           |
| type safety       | compiled                |                                                                                           |

## WTF is Java

Now that I've gone on and one about interpreted and compiled languages, you might notice that Java doesn't seem to fit
cleanly into either category. You compile it with `javac` your source code into `.class` files, but it runs on a JVM?
The best answer is that Java is both!

You compile your `.java` files into the "bytecode" `.class` files, which are optimized for interpretation by the
interpreter. This approach is a good way to get a lot of the benefits of both options. You get the platform independence
of interpreted languages, but can also skip a lot of the steps that slow down interpretation speed. As a result Java is
a special child.
