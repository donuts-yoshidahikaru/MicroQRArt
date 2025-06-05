//
//  ImageLoadingService.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/05.
//

import UIKit
import ReactiveSwift

// MARK: - Protocol
protocol ImageLoadingServiceProtocol {
    func loadImage(from urlString: String?) -> SignalProducer<UIImage?, Never>
}

// MARK: - Implementation
final class ImageLoadingService: ImageLoadingServiceProtocol {
    
    private let session: URLSession
    private let cache: NSCache<NSString, UIImage>
    
    init(session: URLSession = .shared) {
        self.session = session
        self.cache = NSCache<NSString, UIImage>()
        self.cache.countLimit = 100
    }
    
    func loadImage(from urlString: String?) -> SignalProducer<UIImage?, Never> {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return SignalProducer(value: QRCodeImageGenerator.createPlaceholder())
        }
        
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            return SignalProducer(value: cachedImage)
        }
        
        return SignalProducer<UIImage?, Never> { [session, cache] observer, lifetime in
            let task = session.dataTask(with: url) { data, _, error in
                defer { observer.sendCompleted() }

                guard
                    error == nil,
                    let data,
                    let image = UIImage(data: data)
                else {
                    observer.send(value: QRCodeImageGenerator.createPlaceholder())
                    return
                }

                cache.setObject(image, forKey: cacheKey)
                observer.send(value: image)
            }

            task.resume()

            lifetime.observeEnded {
                task.cancel()
            }
        }
    }
}
