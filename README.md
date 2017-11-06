# RACaching

[![CI Status](http://img.shields.io/travis/rallahaseh/RACaching.svg?style=flat)](https://travis-ci.org/rallahaseh/RACaching)
[![Version](https://img.shields.io/cocoapods/v/RACaching.svg?style=flat)](http://cocoapods.org/pods/RACaching)
[![License](https://img.shields.io/cocoapods/l/RACaching.svg?style=flat)](http://cocoapods.org/pods/RACaching)
[![Platform](https://img.shields.io/cocoapods/p/RACaching.svg?style=flat)](http://cocoapods.org/pods/RACaching)

The purpose of the library is to abstract the downloading (images, pdf, zip, etc) and caching of remote resources (images, JSON, XML, etc) in-memory.

<br>
<img src="https://media.giphy.com/media/3otWpsDZJezKeT6bCw/giphy.gif"/>
<br>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
Import the framework

```swift
import RACaching
```

Extend `RAURLObserverProtocol` to the class and define a `RAResourceManager`, which loads all the resources you need from http/https.
<br>
**Resource Manager:**
> - Checks where corresponding resource for a URL in cache using cacheManager, if the resource is not found it checks if already downloading by the downloadsManager.
> - If the resource is not found then it creats resource and initialises download for that resource with adding observers for that resource.
> - If the resource is found in cache it sends the data back to the observer.
> - If the resource is found in the downloadsManager then it adds the observer to the list of resource observer.

Then use 
```swift
open func getDataFor(_ urlString:, withIdentifier identifier:, withUrlObserver observer:)
```
Where it checks if the resource of the URL exists or not to creates new resource if not, the `identifier` here to add observers to a resource and delete it if object does not need data and the `observer` communicate the status of data fetch from Cache or Server

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

RACaching is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RACaching'
```

## Author

rallahaseh, rallahaseh@gmail.com

## License

RACaching is available under the MIT license. See the LICENSE file for more info.
