---
author: Vinicyus Brasil
title: Optimizing Python with Zig for numerical calculations
date: 2025-04-28
description: Using dynamically linked shared object libraries to run a faster Fourth Order Runge-Kutta Method
math: true
cover: contents/en/posts/zig-python-runge-kutta/zig_python.png
---

## Introduction

As a interpreted language, Python is known for being slower than compiled languages when running almost all processes including numerical calculations. It's a trade-off actually, since writing 
compiled languages is normally more complicated (having to deal with pointers, for example) than Python. 

There's a way of profiting from both of the good sides: using dynamically linked shared object libraries. Compiling a function used in the calculation from the compiled language code to a shared object and loading it in Python (where we'll call the function with the parameters) is 
normally faster than just pure Python. 

To exemplify the solution, we'll solve numerically a differential equation using the 4th order Runge Kutta method. The next section will describe the mathematical method, then the Zig code will be explained and then how to do the Python integration. Here we'll be using Zig as our compiled language but the same ideia can be used for C/C++ or other language that can use the C bindings.

The code is available [here](https://github.com/vinybrasil/zig-python-runge-kutta). The Python version used is 3.12.3 (with numba 0.61 and cffi 1.71) and the Zig version is 0.14. 


## Fourth Order Runge-Kutta Method

The equation used for this example is from [Doherty Andrade's article](https://metodosnumericos.com.br/pdfs/RK4aordem.pdf):

$$ y' + 2xy  = 4x $$

with $ y(0) = 1 $ at the interval  $ [ 0, 2 ] $ and this particular equation has the analytical solution $ y(x) = 2 - \text{exp} (-x²) $ which can be used to verify the solution. 

This is a initial value problem (IVP) where we have the following system:



$$
\begin{aligned}
y' = f(x, y) \cr
y(x_0) = y_0
\end{aligned}
$$



To solve the equation numerically in the interval, following the 4th Order Runge-Kutta Method we need to calculate for coefficients:

$$
\begin{aligned}
K_1 &= h f(x_k, y_k) \cr
K_2 &= h f(x_k + \frac{1}{2} h, y_k + \frac{1}{2} K_1) \cr
K_3 &= h f(x_k + \frac{1}{2} h, y_k + \frac{1}{2} K_2) \cr
K_4 &= h f(x_k + h, y_k + K_3)
\end{aligned}
$$
where $h \in R$ is chosen arbitarily. Our numerical solution (the $y_{k+1}$ values) is defined by
$$ y_{k+1} = y_k + \frac{1}{6} (K_1 + 2 K_2 + 2 K_3 + K_4) $$

for points in the interval $ x_k \leq x \leq x_{k+1} $.

## Zig code: building the static library

We first need to create the zig files.
```bash
mkdir zigcode  && cd zigcode && zig init
```

The structure of the project is the following:
```
zig-python-runge-kutta/
│
├── zigcode/            
│   ├── src/                # Created automatically
│   │   ├── main.zig
|   ├── build.zig
│   ├── libmain.so          # The file genereated by the compilation 
├── run.py                  # Where 
```

The libmain.so is the file generated when we compile the code. The **main.zig** file contains four functions. The first is **evaluate**, which calculates $f(x,y)$, and the other **rk4ordem**, which receives the parameters of the problem and calculates  the vector containing the values $y_k$. It also uses a memory allocator so it can dinamically allocate memory to create the vectors (which size can be known only in runtime).

```zig
const std = @import("std");


fn rk4ordem(
    yinit: f64,
    xrange: *const [2]f64,
    h: f64,
    allocator: std.mem.Allocator,
    n: usize,
) anyerror![]f64 {
    const ys = try allocator.alloc(f64, n + 1);
    errdefer allocator.free(ys);

    const xs = try allocator.alloc(f64, n + 1);
    defer allocator.free(xs);

    xs[0] = xrange[0];

    ys[0] = yinit;

    var x = xrange[0];
    var y = yinit;

    var ks = [4]f64{ 0.0, 0.0, 0.0, 0.0 };

    for (1..n + 1) |i| {
        ks[0] = h * evaluate(x, y);
        ks[1] = h * evaluate(x + h * 0.5, y + ks[0] * (h * 0.5));
        ks[2] = h * evaluate(x + h * 0.5, y + ks[1] * (0.5));
        ks[3] = h * evaluate(x + h, y + ks[2]);

        y = y + (1.0 / 6.0) * (ks[0] + (2 * ks[1]) + (2 * ks[2]) + ks[3]);
        x = x + h;

        ys[i] = y;
    }

    return ys;
}

fn evaluate(x: f64, y: f64) f64 {
    const result_evaluation: f64 = 4.0 * x - 2.0 * x * y;
    return result_evaluation;
}
```

Now we need to create a function that we'll connect what the Zig library receives from the Python code. It mainly uses
C types because this project will use the ctypes library on the Python's side. 
```zig 
export fn main(
    h: c_longdouble,
    xrange_0: c_longdouble,
    xrange_1: c_longdouble,
    yinit_0: c_longdouble,
) [*]c_longdouble {
    const allocator = std.heap.page_allocator;

    var xrange = [2]f64{
        @floatCast(xrange_0),
        @floatCast(xrange_1),
    };

    const yinit: f64 = @floatCast(yinit_0);
    const h_float: f64 = @floatCast(h);
    const n: usize = @intFromFloat((xrange[1] - xrange[0]) / h_float);

    var result3: [1]c_longdouble = undefined;

    const pot: [*c]c_longdouble = @constCast(&result3);

    var result2 = allocator.alloc(c_longdouble, n + 1) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return pot;
    };

    errdefer allocator.free(result2);

    const result = rk4ordem(
        yinit,
        &xrange,
        h_float,
        allocator,
        n,
    ) catch |err| {
        std.debug.prfree_resultsint("Error: {}\n", .{err});
        allocator.free(result2);
        return pot;
    };

    defer allocator.free(result);

    for (result, 0..) |val, i| {
        result2[i] = @floatCast(val);
    }

    const pot2: [*c]c_longdouble = @ptrCast(result2);

    return pot2;
}

export fn free_results(ptr: [*c]c_longdouble, len: usize) void {
    const allocator = std.heap.page_allocator;
    const slice = ptr[0..len];
    allocator.free(slice);
}
```

Compiling the project will result in a shared object (.so) file.

```bash
zig build-lib src/main.zig -dynamic -Doptimize=ReleaseFast
```

## Python code and comparision

In our **run.py** file, we'll create an object that loads the shared object file when it inits. Then create a function called **calcular** that calls the main
function of our zig code. Note we are explicit saying which type of the argtypes are (here they are all long doubles) and also the type of result (a pointer to a longdouble). Note we are also calling the **free_results** functions to clear the memory and prevent a memory leak.

```python
import ctypes
import time


class SolverClass:
    def __init__(self):
        self.ziglibrary = ctypes.CDLL(
            "zigcode/libmain.so"
        )

    def calcular(self, h, xrange_0, xrange_1, yinit_0):
        self.ziglibrary.main.argtypes = [
            ctypes.c_longdouble,
            ctypes.c_longdouble,
            ctypes.c_longdouble,
            ctypes.c_longdouble,
        ]

        self.ziglibrary.main.restype = ctypes.POINTER(ctypes.c_longdouble)

        return self.ziglibrary.main(h, xrange_0, xrange_1, yinit_0)


h = 0.000_001 
xrange_0, xrange_1 = (0.0, 2.0)
yinit = 1.0
n = int((xrange_1 - xrange_0) / h)

print(f"number of points: {n}")


## zig execution
start_time = time.time()
classe = SolverClass()
result = classe.calcular(h=h, xrange_0=xrange_0, xrange_1=xrange_1, yinit_0=yinit)
result_a = [result[i] for i in range(n + 1)]

classe.ziglibrary.free_results(result, n + 1)

print(f"zig: {time.time() - start_time}")
```
Let's implement the mathematical method in Python. We'll be using JIT to compile the code 
so it can run way faster than normal Python. 
```python
import numpy as np
from numba import jit


@jit(nopython=True)
def RK4Ordem(yinit, xrange_0, xrange_1, h):
    n = int((xrange_1 - xrange_0) / h)

    xsol = np.zeros(n + 1)
    ysol = np.zeros(n + 1)
    ysol[0] = yinit
    xsol[0] = xrange_0

    x = xsol[0]
    y = ysol[0]

    for i in range(1, n + 1):
        k1 = h * evaluate(x, y)
        k2 = h * evaluate(x + h / 2, y + k1 * (h / 2))
        k3 = h * evaluate(x + h / 2, y + k2 * (1 / 2))
        k4 = h * evaluate(x + h, y + k3)

        y = y + (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4)
        x = x + h

        xsol[i] = x
        ysol[i] = y

    return [xsol, ysol]


@jit(nopython=True)
def evaluate(x, y):
    return 4 * x - 2 * x * y


## JIT execution
start_time = time.time()
[ts, ys] = RK4Ordem(yinit, xrange_0, xrange_1, h)
print(f"jit: {time.time() - start_time}")
``` 

In this experiment we'll be using $ h = 10^{-6} $ we'll have a number of points equal to $ 2 * 10^6 $. The following table show the results of the test.
| Type          | average time (seconds) |
| --------      | :-------: |
| Without JIT   | more than 36 seconds   |
| With JIT      | 0.3942    |
| With Zig      | 0.2155  |

It's a almost 45% reduction in the time spent. It's true that part of it is because the of the compilation of JIT and if you would run
it multiple times the JIT version would consume less time but that goes beyond the scope of this article.


And that's it for today. The full code is available [here](https://github.com/vinybrasil/zig-python-runge-kutta). Keep on learning :D