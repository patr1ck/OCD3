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
<<<<<<< Local Changes

## Tutorial

In this tutorial, we will walk through the steps needed to create an animated bar chart which follows
a [random walk](http://en.wikipedia.org/wiki/Random_walk). The full code is listed in the BarChartView.m
example view.

##### Setup

The first thing we do is create an OCDView and add it to our view heirarchy.

```objc
OCDView *movingBarView = [[OCDView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kBarMaxHeight)];
[self addSubview:movingBarView];
self.movingBarView = movingBarView;
_vector = (kBarMinHeight + kBarMaxHeight)/2;
_time = 0;
_barWidth = (self.bounds.size.width + kBarDataPerScreen) / kBarDataPerScreen;
```

Here, we also set a few variables. 
* `_vector`, our inital data point, to be between the max and min heights of our desired bar chart
* `_barWidth` the width of each bar in our bar chart
* `_vector` an arbitrary increasing value we use as part of our data set

Next, we populate our data set with some inital data.

```objc
self.randomWalkData = [NSMutableArray arrayWithCapacity:10];
for (int i = 0; i < kBarDataPerScreen; i++) {
    [self.randomWalkData addObject:[self nextData]];
}

...

- (NSDictionary *)nextData
{
    int value = MAX(kBarMinHeight, MIN(kBarMaxHeight, abs(_vector + kBarMinHeight * ( (((double)arc4random() / ARC4RANDOM_MAX)) - 0.5) )));
    _vector = value;
    return @{ @"value": [NSNumber numberWithInt:value], @"time": [NSNumber numberWithInt:_time++] };
}
```
As you can see from the above, our data set will be an array full of dictionaries, each with
@"value" and @"time" keys. We'll see how this is used in a moment. For now, we're going to do
some actual drawing with OCD3. Let's create a simple black baseline for our chart.

```objc
OCDNode *line = [OCDNode nodeWithIdentifier:@"line"];
line.nodeType = OCDNodeTypeLine;
[line setValue:[NSValue valueWithCGPoint:CGPointMake(0, kBarMaxHeight - 0.5)]
forAttributePath:@"shape.startPoint"];
[line setValue:[NSValue valueWithCGPoint:CGPointMake(movingBarView.bounds.size.width, kBarMaxHeight - 0.5)]
forAttributePath:@"shape.endPoint"];
[line setValue:[NSNumber numberWithInt:100] forAttributePath:@"zPosition"];
[line updateAttributes];
[self.movingBarView appendNode:line];
```

Here, we create a new node and give it the identifier "line", although we could have called
it anything we wanted. We then set it's `nodeType` to be that of `OCDNodeTypeLine` and configure 
its start and end points. Note that `setValue:forAttributePath:` method – you'll be seeing it 
a lot. By using the special path prefix "shape", you can configure the shape attributes particular
to this node's type. You can also use this method to set arbirtary properties on the underlying 
layer a-la [KVC](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/KeyValueCoding/Articles/Overview.html),
like how we set the zPosition – to make sure this node is always in front of the other elements in our
bar chart.

Once we've set our properties, we call `updateAttributes` to force the node to apply its attributes,
and then we call `appendNode:` on the view. This adds the shape layer as well as does some bookkeeping
for OCD3.
 
Finally, we'll create a timer to have our chart redraw every few seconds, and call the method which draws our chart:

```objc
NSTimer *timer = [NSTimer timerWithTimeInterval:2
                                         target:self
                                       selector:@selector(stepData)
                                       userInfo:nil
                                        repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
[self redrawChart];
```

##### Data Driven Drawing

Now we can really start to leverage the power of OCD3. Let's take a look at our `redrawChart` method.
Ignoring the first few lines about scales, we see the following:

```objc    
OCDSelection *bars = [self.movingBarView selectAllWithIdentifier:@"bar"];
[bars setData:self.randomWalkData usingKey:@"time"];
```

Here, we create a *selection* of nodes that with the "bar" identifier, and then we set data on that
selection. We use the key "time" to identify data already in existing nodes, should they exist. At 
this point, they don't, but we'll see why this is important later.

So what does it mean to "set data on a selection"? It means that our array of data has been joined
with nodes in our view. Depending on the view's current state, some nodes maybe added to show new 
data, some may be removed to get rid of old data, some may simply be updated, to reflect new data. 
How each of these operations occur is up to us to define. We do this be setting enter, update, and 
exit blocks that correspond to each of these possiblities.

In this particular example, on first run of `redrawChart`, our selection will create new nodes for
each data point. It then waits for us to define an enter block which will be executed for these 
nodes. Let's take a look at the next few lines:

```objc
[bars setEnter:^(OCDNode *node) {
  
  [node setNodeType:OCDNodeTypeRectangle];

  [node setValue:^(id data, NSUInteger index){
      CGFloat scaledValue = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
      return [NSNumber numberWithFloat:scaledValue + index];
  } forAttributePath:@"position.x"];

  [node setValue:^(id data, NSUInteger index){
      CGFloat computed = kBarMaxHeight - [[yScale scaleValue:[data objectForKey:@"value"]] floatValue];
      return [NSNumber numberWithFloat:computed];
  } forAttributePath:@"position.y"];

  [node setValue:[NSNumber numberWithFloat:_barWidth] forAttributePath:@"shape.width"];
  [node setValue:^(id data, NSUInteger index){
      return [yScale scaleValue:[data objectForKey:@"value"]];
  } forAttributePath:@"shape.height"];

  double hue = (double) arc4random() / ARC4RANDOM_MAX;
  [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];

  [node setText:[NSString stringWithFormat:@"%.0f", [[node.data objectForKey:@"value"] floatValue]]];
  ...
```

As you can see, this very similar to our previous example, but with a very notable exception. Here,
rather than always setting values, we are setting blocks for certain attribute paths. `setValue:forAttributePath:`
can take a special `OCDSelectionValueBlock`, which gets passed two arguments: The data value being
represented, and the index of the object in the array. It must return an object which can be set
for that attribute path.

Further, we can also set animations for the newly appearing node:

```objc
[node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
    CGFloat scaledValueFrom = [[xScale scaleValue:[NSNumber numberWithInt:index+1]] floatValue];
    CGFloat scaledValueTo = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
    
    move.fromValue = [NSNumber numberWithFloat:scaledValueFrom + index];
    move.toValue = [NSNumber numberWithFloat:scaledValueTo + index];
    
    move.duration = 1.0f;
    [animationGroup setAnimations:@[move]];
} completion:nil];
```

Here, we're going to have it move in from the right.

To finish off our enter block, we append the node to the view.

```objc
...
    [self.movingBarView appendNode:node];
}];
```