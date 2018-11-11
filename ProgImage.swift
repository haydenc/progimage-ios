
class UIProgImageView: UIImageView{
    let BASE_PROG_IMAGE_URL = "https://progimage.com"
    var remoteImageId: Int?
    var queuedTransforms: [Transform] = []

    func store() -> Promise<Int>{
        return Promise<Int>{ (seal: Resolver) in
            if(self.remoteImageId == nil){
                let url = String(format: "%@/api/library/images/", self.BASE_PROG_IMAGE_URL)
                let imageData = self.image!.pngData()!

                Alamofire.upload(imageData, to: url).responseJSON { (responseData) -> Void in
                    if((responseData.result.value) != nil) {
                        let imageResponseData = JSON(responseData.result.value!)
                        let imageId = imageResponseData["id"].int
                        seal.resolve(imageId, nil)
                    }else{
                        seal.reject(AFError.responseValidationFailed(reason: .unacceptableContentType(acceptableContentTypes: ["json"], responseContentType: "html")))
                    }
                }
            }else{
                // Already saved this one, just resolve immediately
                seal.resolve(self.remoteImageId, nil)
            }
        }
    }

    private func execTransforms(_ transforms: [Transform]) -> Promise<UIImage>{
        return Promise<UIImage>{ (seal: Resolver) in
            let url = String(format: "%@/api/library/images/%@/", self.BASE_PROG_IMAGE_URL, self.remoteImageId!.description)

            // Build up the data for the transforms individually
            var transform_data: [Dictionary<String, Any>] = []
            for transform in transforms{
                transform_data.append(transform.serialize())
            }

            let parameters = ["transforms": JSON(transform_data)]

            Alamofire.request(url,
                              method: HTTPMethod.post,
                              parameters: parameters,
                              encoding: JSONEncoding.default
                ).responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        seal.resolve(image, nil)
                    }
                }
        }
    }

    func executeTransforms() -> Promise<Void>{
        return execTransforms(self.queuedTransforms).done{ (newImage: UIImage) in
            // Update the UI with our transformed image
            self.image = newImage
        }
    }

    /*** Shortcut methods ***/

    func rotate(_ degrees: Double){
        // Queue up rotation
        self.queuedTransforms.append(Rotation(degrees))
    }

    func scale(_ multiplier: Double){
        // Queue up scaling transformation
        self.queuedTransforms.append(Scale(multiplier))
    }

    func crop(_ x: Int, _ y: Int, _ width: Int, _ height: Int){
        // Queue up rotation
        self.queuedTransforms.append(Crop(x, y, width, height))
    }
}
