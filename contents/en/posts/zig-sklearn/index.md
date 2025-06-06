---
author: Vinicyus Brasil
title: Running sklearn models in Zig
date: 2025-02-06
description: Learn how to execute predictions from scikit-learn models in Zig with the Python's C API and the Zap webframework
math: false
---

## Introduction


Scikit-learn models became the industry standard for creating machine learning models.
Although the library offers many conveniences, one becomes tied to Python APIs for serving such models. These frameworks (such as FastAPI, for example) have various scalability issues, as Anton demonstrates in this video.
To overcome this limitation, one solution is to use Python's C library to run the models, while the rest of the API can be built using another framework.

In this blogpost we'll implement this strategy. We'll create an application that uses Python's C API to run the models with the [Zap](https://github.com/zigzap/zap) library handling the requests,
which is a Zig `blazing fast microframework for web applications`.
The full code to the post can be found in this [repository](https://github.com/vinybrasil/zig-sklearn).


## Creating the model and the shared object

So let's say we got this simple script called **train.py** that creates a Logistic Regression, in which the model takes a numpy array 
with two dimensions and returns the value 1 or 0.  The model is saved in a pickle file called **model.pkl**.

```python
import numpy as np
from sklearn.linear_model import LogisticRegression
import pickle

X = np.array([
    [1.2, 1.3],
    [2.2, 1.4],
    [0.9, 2.1],
    [-1.2, -2.3],
    [-1.3, -0.2],
    [-1.1, -2.8],
])

y = np.array([[1],[1],[1],[0],[0],[0]])

y = y.ravel()
model = LogisticRegression()

model.fit(X, y)

with open('model.pkl', 'wb') as handle:
    pickle.dump(model, handle)
```

The full library we are going to create just loads the pickle file and returns it in a list. It will attend by the name of `libpredict`
and it **predict_sklearn.py** module have the following code:

```python
import numpy as np
import pickle

def predict(x):
    with open('./model.pkl', 'rb') as handle:
        b_1 = pickle.load(handle)
    
    return [float(b_1.predict(np.array(x).reshape(1, -1))[0])]
```
Quite simple, right? The next step is to compile it to a shared object, the kind of file that contains the code we just wrote. 
Theoretically this step is not needed but I think its way easier to work with the library this way. 

To compile the library we can use Cython. The following **setup.py** file will translate our library to C and generate the shared object.

```python
from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import sysconfig


python_inc = sysconfig.get_path("include")
python_lib = sysconfig.get_config_var("LIBDIR")
python_version = sysconfig.get_config_var("VERSION")
python_shared = f"python{python_version}"

extensions = cythonize(
    Extension(
        name="libpredict",
        sources=["libpredict/predict_sklearn.py"],
        libraries=[python_shared],  
        library_dirs=[python_lib],  
        include_dirs=[python_inc], 
        extra_link_args=[
            "-Wl,-rpath," + python_lib,  
            "-Wl,--no-as-needed",  
        ],
    )
)

setup(
    name="libpredict",
    packages=find_packages(),
    ext_modules=extensions,
)
```
Note that both of the files generated, libpredict.so and model.pkl, need to be moved to the same folder where we'll build the zig executable.

## Running Python code in Zig 

To interact with the Python C API, we gotta load the header file that includes the Python functions. The **main.zig** file starts with: 
```zig 
const c = @cImport({
    @cInclude("Python.h");
});
``` 
The syntax to call Python is in this [documentation](https://docs.python.org/3/c-api/index.html). For exemple,
to print a string, we first need to initialize the interpreter and use the function PyRun_SimpleString 
with the string. 

```
    c.Py_Initialize();
    _ = c.PyRun_SimpleString("import sys; sys.path.append('.');");
    c.Py_Finalize();
```
The main.zig file will start this way. First, we initialize the interpreter. Then, load the module **libpredict** 
and extracts from it a pointer to the function **predict** from the **predict_sklearn.py**. To call the function 
 we need to convert the zig array **doubles2** to a Python List also using the C API and that's the reason for the 
 function **prepareList** to exist. Finally, the function can be called using the converted list.
```
pub fn main() !void {
    c.Py_Initialize();

    _ = c.PyRun_SimpleString("import sys; sys.path.append('.');");

    const module = try loadMod();

    const func = try loadFunc(module);

    var doubles2 = [_]f64{ 1.2, 1.3 };

    const pList = try prepareList(doubles2[0..]);

    const result = evaluteResult(pList, func);

    std.debug.print("Test: {any}\n", .{result});

    _ = c.Py_DecRef(func);
    _ = c.Py_DecRef(module);
}
```

Note the loadMod() function appends the current path and from it import the **libpredict.so** file so the loadFunc function can link 
a pointer to the predict function. 


```zig
pub fn loadMod() !*c.PyObject {
    const sys = c.PyImport_ImportModule("sys");
    const path = c.PyObject_GetAttrString(sys, "path");
    _ = c.PyList_Append(path, c.PyUnicode_FromString("."));

    const module = c.PyImport_ImportModule("libpredict");
    return module;
}

pub fn loadFunc(module: *c.PyObject) !*c.PyObject {
    const func = c.PyObject_GetAttrString(module, "predict");
    return func;
}
```
The prepareList function just creates a Python list with PyList_New and appends to it the values from the **doubles** arrayh.
```zig
pub fn prepareList(doubles: []f64) !*c.PyObject {
    const pList = c.PyList_New(0);

    for (doubles) |elem| {
        const pValue = c.PyFloat_FromDouble(elem);

        if (c.PyList_Append(pList, pValue) != 0) {
            c.PyErr_Print();
        }
        _ = c.Py_DecRef(pValue);
    }

    return pList;
}
```
The evaluteResult function iterates through all of the values of the Python function's response and the returns the last one. I've written the code 
this way because maybe what you are interested is the return of the predict_proba() function of the sklearn model, so it's easier to adapt the code.
```zig
pub fn evaluteResult(pList: *c.PyObject, func: *c.PyObject) !f64 {
    const args = c.PyTuple_Pack(1, pList);
    const value = c.PyObject_CallObject(func, args);

    var result: f64 = undefined;
    if (value != null) {
        const list_size: usize = @intCast(c.PyList_Size(value));

        for (0..list_size) |i| {
            const index: isize = @intCast(i);
            const pItem = c.PyList_GetItem(value, index);
            const pValue = c.PyFloat_AsDouble(pItem);

            std.debug.print("Result = {d}\n", .{pValue});
            result = pValue;
        }

        _ = c.Py_DecRef(value);
    } else {
        c.PyErr_Print();
    }
    _ = c.Py_DecRef(args);
    return result;
}
```


## Creating the API with Zap 

I've chosen Zap because it's a *blazing fast* micro webframework that can handle a lot of requests simultaneously
and also it's quite intuitive.


To create the API, we need a Router object to map the routes to the functions that handle the requests. Our only route here is the **predict**
that receives a json payload with the fields **parameter1** and **parameter2** to send to the Python function. We'll also need a HttpListener object 
to listen to the requests on the port 3000. The struct PredictorPackage is where all of the handling of the request is made;

```zig
pub fn main() !void {

    ...

    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};

    const allocator = gpa.allocator();

    var simpleRouter = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer simpleRouter.deinit();

    const doubles = try allocator.alloc(f64, 2);
    defer allocator.free(doubles);

    var somePackage = PredictorPackage.init(
        allocator,
        doubles[0..],
        func,
    );

    try simpleRouter.handle_func("/predict", &somePackage, &PredictorPackage.predictValue);

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = simpleRouter.on_request_handler(),
        .log = true,
        .max_clients = 100000,
    });
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1,
    });
}
```

Inside the PredictorPackage struct, the function predictValue captures the body of the request, parses it with std.json.Parsed and then 
calls the Python function with it. Then, it stringify it and responds the request with a resultPrediction object. 
```zig
pub const valueToPredict = struct {
    parameter1: f64,
    parameter2: f64,
};

pub const resultPrediction = struct {
    predictedClass: f64,
};

pub const PredictorPackage = struct {
    const Self = @This();

    allocator: Allocator,
    doubles: []f64,
    func: *c.PyObject,

    pub fn init(
        allocator: Allocator,
        doubles: []f64,
        func: *c.PyObject,
    ) Self {
        return .{
            .allocator = allocator,
            .doubles = doubles,
            .func = func,
        };
    }

    pub fn predictValue(self: *Self, req: zap.Request) void {
        std.log.warn("predict_value_requested", .{});

        if (std.mem.eql(u8, req.method.?, "POST")) {
            std.debug.print("Preparing to predict\n", .{});

            req.parseBody() catch |err| {
                std.log.err("Parse Body error: {any}. Expected if body is empty", .{err});
            };

            if (req.body) |body| {
                const maybe_user: ?std.json.Parsed(std.json.Value) = std.json.parseFromSlice(std.json.Value, self.allocator, body, .{}) catch null;

                if (maybe_user) |parsed_user| {
                    defer parsed_user.deinit();

                    if (parsed_user.value.object.get("parameter1")) |parameter1| {
                        self.doubles[0] = parameter1.float;
                    }
                    if (parsed_user.value.object.get("parameter2")) |parameter2| {
                        self.doubles[1] = parameter2.float;
                    }
                    std.log.info("Parameter1: {?}", .{self.doubles[0]});
                    std.log.info("Parameter2: {?}", .{self.doubles[1]});
                } else {
                    std.log.err("Failed to parse JSON", .{});
                }
            }

            // predict

            std.debug.print("vector to predict: {any}\n", .{self.doubles[0..]});

            const pList = try prepareList(self.doubles[0..]);

            const result = try evaluteResult(pList, self.func);

            std.debug.print("resultado: {any}\n", .{result});

            //transform prediction into json
            const resultSend = resultPrediction{ .predictedClass = result };

            var buf: [100]u8 = undefined;
            var json_to_send: []const u8 = undefined;
            if (zap.stringifyBuf(&buf, resultSend, .{})) |json| {
                json_to_send = json;
            } else {
                json_to_send = "null";
            }

            // send prediction back to the client
            req.setContentType(.JSON) catch return;
            req.sendBody(json_to_send) catch return;
        }
    }
};

```

The full main.zig file, as well as a dockerfile with all of the components, can be found in the [repository of the project](https://github.com/vinybrasil/zig-sklearn).

After building the project (**zig build run**) and moving the libpredict.so and the model.pkl to the same folder as the executable,
we can test the API with cURL: 
```bash
curl -X POST http://localhost:3000/predict \
     -H "Content-Type: application/json" \
     --data '{"parameter1": -1.3, "parameter2": -1.4}'
```
It should return the following response:
```bash
{
    "predictedClass": 0e0
}
```

And that's it. Fell free to contact me via Linkedin or to open a PR on the GitHub repo if you find something wrong. Keep on learning :D
