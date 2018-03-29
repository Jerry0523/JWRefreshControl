[![Build Status](https://travis-ci.org/Jerry0523/JWRefreshControl.svg?branch=master)](https://travis-ci.org/Jerry0523/JWRefreshControl)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JWRefreshControl.svg)](https://img.shields.io/cocoapods/v/JWRefreshControl.svg)

# JWRefreshControlDemo
A refresh control(refresh header &amp; footer for scrollview) for iOS app.

![alt tag](https://raw.githubusercontent.com/Jerry0523/JWRefreshControl/master/screenshot.gif)

Usage
-------

### Add a refresh header

```swift
self.tableView.addRefreshHeader { [weak self] (header) in
    //fetch data and reload UI
}
```

### Add a refresh footer

```swift
self.tableView.addRefreshFooter { [weak self] (footer) in
    //fetch data and reload UI
}
```

### Custom Content View Supported
```swift
self.webView.scrollView.addCustomRefreshHeader { [weak self] (header: RefreshHeaderControl<SloganHeaderContentView>) in
    self?.webView.reload()
    header.success()
}
```

### Completion Handler

- Notify refresh successfully
```swift
self.tableView.refreshHeader.success()
```

- Notify refresh error
```swift
self.tableView.refreshHeader.error(withMsg: "Network Error")
```

- Notify no more data
```swift
self.tableView.refreshFooter.pause(withMsg: "No More Data")
```

- Notify fetch task to stop
```swift
self.tableView.refreshHeader.stop()
```

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries. You can install it with the following command:

```bash
$ gem install cocoapods
```
#### Podfile

To integrate JWIntent into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'JWRefreshControl'
```

Then, run the following command:

```bash
$ pod install
```

License
-------
(MIT license)

