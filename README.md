# OCD3


A not-yet-primetime-ready, Core Animation-based, D3.js-inspired drawing library for Cocoa Touch.
Specifically, OCD3 uses CAShapeLayer, along with CAAnimations and D3.js-style enter/update/exit 
patterns to do data-bound drawing in a view.

While not quite a D3.js port, it is still a good idea to have a general understanding of D3.js
before diving into this code. Here are some good tutorials:

[Three Little Circles](http://mbostock.github.com/d3/tutorial/circle.html)   
[A Bar Chart, Part 1](http://mbostock.github.com/d3/tutorial/bar-1.html)    
[A Bar Chart, Part 2](http://mbostock.github.com/d3/tutorial/bar-2.html)

The code for these tutorials (along with some others, like [Pie Chart](http://bl.ocks.org/mbostock/3887235)
and [OMG Particles](http://bl.ocks.org/mbostock/1062544)) are implemented in the provided 
sample app.

OCD3 is still under heavy alpha development, so its API is subject to change. It's not
recommended to use it in production code until a formal release/annoucement is made. 
Versioning will, at some point, follow [SemVer](http://semver.org/).

## Concepts

An `OCDView` plays host to all OCD3 content. This view is typically made up of 1 or more `OCDNodes`. 
These nodes are analogous to DOM nodes in an SVG element. Here, they are act as smart wrappers 
around CAShapeLayers. While you can specify the shape by using the OCDNode's `-setNodeType:` method
and then manually add it to a view, there are more powerful ways of drawing in OCD3 which you can
leverage, which we will talk about in a moment.

OCD3 provides an `OCDSelection` class, which is returned when you "select" nodes from an OCDView.
Once you have a selection you can bind an array of data to those nodes, which can then act as a
representation of the data. Nodes that don't already exist in the view are created, ones that are
no longer needed are destroyed, and others are updated as needed. This is known as a [data-join](http://bost.ocks.org/mike/join/).

OCD3 also provides `OCDScale`, `OCDNodeFormatter`, and `OCD*Layout` classes. `OCDScale` is analogous
to `d3.scale`, `OCDNodeFormatter` is analogous to the `d3.svg` shape generators, and the `OCD*Layout`
classes try to help with node layout, similar to the `d3.layout` library.

## Documentation

Soon!
