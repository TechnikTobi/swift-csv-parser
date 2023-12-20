# Swift CSV Parser
A more advanced CSV parser for Swift 5.

Usage: 
```swift
let rawContent = try String(contentsOf: path, encoding: .utf8);
let parsedData = try rawContent.asCSVdata(separatedBy: ",");
```
