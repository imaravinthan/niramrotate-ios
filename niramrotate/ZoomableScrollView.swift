//
//  ZoomableScrollView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 22/12/25.
//


import SwiftUI
import UIKit

struct ZoomableScrollView: UIViewRepresentable {

    let imageURL: URL
    let onSingleTap: () -> Void

    func makeUIView(context: Context) -> UIScrollView {

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.delegate = context.coordinator

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.decelerationRate = .fast

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView

        // Load image
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: imageURL)

                guard let http = response as? HTTPURLResponse,
                      (200..<300).contains(http.statusCode),
                      let image = UIImage(data: data) else {
                    return
                }

                await MainActor.run {
                    imageView.image = image
                    imageView.frame = CGRect(origin: .zero, size: image.size)
                    scrollView.contentSize = image.size
                    context.coordinator.setInitialZoom()
                }

            } catch {
                print("❌ Image load failed:", error)
            }
        }


        // Single tap
        let singleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.singleTap)
        )
        singleTap.numberOfTapsRequired = 1

        // Double tap zoom
        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.doubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2

        singleTap.require(toFail: doubleTap)

        scrollView.addGestureRecognizer(singleTap)
        scrollView.addGestureRecognizer(doubleTap)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSingleTap: onSingleTap)
    }
    
    func loadImageData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    
    // MARK: - Coordinator
    final class Coordinator: NSObject, UIScrollViewDelegate {

        var imageView: UIImageView?
        var scrollView: UIScrollView?
        let onSingleTap: () -> Void

        init(onSingleTap: @escaping () -> Void) {
            self.onSingleTap = onSingleTap
        }
        
        func setInitialZoom() {
            guard let scrollView,
                  let imageView,
                  let image = imageView.image else { return }

            let widthScale = scrollView.bounds.width / image.size.width
            let heightScale = scrollView.bounds.height / image.size.height
            let minScale = min(widthScale, heightScale)

            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 6
            scrollView.zoomScale = minScale

            centerImage()
        }


        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage()
        }

        func centerImage() {
            guard let scrollView, let imageView else { return }

            let bounds = scrollView.bounds.size
            var frame = imageView.frame

            frame.origin.x = frame.size.width < bounds.width
                ? (bounds.width - frame.size.width) / 2
                : 0

            frame.origin.y = frame.size.height < bounds.height
                ? (bounds.height - frame.size.height) / 2
                : 0

            imageView.frame = frame
        }

        @objc func singleTap() {
            onSingleTap()
        }

        @objc func doubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView else { return }

            if scrollView.zoomScale > 1 {
                scrollView.setZoomScale(1, animated: true)
            } else {
                let point = gesture.location(in: gesture.view)
                let zoomRect = zoomRectForScale(scale: 2.5, center: point)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }

        private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
            guard let scrollView else { return .zero }

            let size = scrollView.bounds.size
            let width = size.width / scale
            let height = size.height / scale

            return CGRect(
                x: center.x - width / 2,
                y: center.y - height / 2,
                width: width,
                height: height
            )
        }
    }
}
