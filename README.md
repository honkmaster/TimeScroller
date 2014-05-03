# TimeScroller

`TimeScroller` is a `UIView` that hovers beside the scroll bar of a `UITableView`. This design paradigma was introduced by [Path](https://itunes.apple.com/us/app/path/id403639508?mt=8). `TimeScroller` was implemented using the least possible external ressources (images, ...). The design is, obviously, ready for iOS 7.

<img src=http://oi57.tinypic.com/2nivdqh.jpg width="320px" />

## Used In
- Please tell me if you use `TimeScroller` in your App (just submit it as an [issue](https://github.com/honkmaster/TimeScroller/issues))! 

## Requirements

- Frameworks: QuartzCore, UIKit, Foundation
- This project uses ARC. If you want to use it in a non ARC project, you must add the `-fobjc-arc` compiler flag to TTOpenInAppActivity.m in Target Settings > Build Phases > Compile Sources.

## License

Copyright (c) 2014 Tobias Tiemerding

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Thanks

Andrew Roy Carter for his [ACTimeScroller](https://github.com/andrewroycarter/TimeScroller), which is (at the moment) no longer in active development and thus lead to this implementation.
