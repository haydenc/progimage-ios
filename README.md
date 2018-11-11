# progimage-ios
iOS Shim for the ProgImage API

## Example usage

```swift
let imageView = imageView as! UIProgImageView
imageView.rotate(45.0)
imageView.executeTransforms()
```
Note that nothing happens without the call to `executeTransforms` - this is to prevent multiple calls for bulk transformations
