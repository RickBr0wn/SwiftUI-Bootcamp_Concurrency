//
//  DownloadImagesUsingAsyncAwait.swift
//  SwiftUI-Bootcamp
//
//  Created by Rick Brown on 03/07/2022.
//

import SwiftUI
import Combine

class DownloadImagesUsingAsyncAwaitImageLoader {
  let url = URL(string: "https://picsum.photos/300")!
  
  public func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
    guard
      let data = data,
      let image = UIImage(data: data),
      let response = response as? HTTPURLResponse,
      response.statusCode >= 200 && response.statusCode < 300
    else {
      return nil
    }
    return image
  }
  
  public func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) -> Void {
    /// Automatically switches to the background thread
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      let image = self?.handleResponse(data: data, response: response)
      completionHandler(image, error)
      
    }
    .resume()
  }
  
  public func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
      .map(handleResponse)
      .mapError({ $0 })
      .eraseToAnyPublisher()
    
  }
  
  public func downloadWithAsyncAwait() async throws -> UIImage? {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      return handleResponse(data: data, response: response)
    } catch {
      throw error
    }
  }
}

class DownloadImagesUsingAsyncAwaitViewModel: ObservableObject {
  @Published var image: UIImage? = nil
  private let loader = DownloadImagesUsingAsyncAwaitImageLoader()
  
  private var cancellables: Set<AnyCancellable> = []
  
  public func fetchImage() async -> Void {
    // Using @escaping closures
    /*
     loader.downloadWithEscaping { [weak self] image, error in
     DispatchQueue.main.async { self?.image = image }
     }
     */
    // Using the combine pipeline
    /*
     loader.downloadWithCombine()
     .receive(on: DispatchQueue.main)
     .sink { _ in
     } receiveValue: { [weak self] image in
     self?.image = image
     }
     .store(in: &cancellables)
     */
    
    // Using async/await
    // Once again using optional try to ignore any potential errors, rather
    // than handling them in a try catch block
    let image = try? await loader.downloadWithAsyncAwait()
    await MainActor.run { self.image = image }
  }
}

struct DownloadImagesUsingAsyncAwait: View {
  @StateObject private var vm = DownloadImagesUsingAsyncAwaitViewModel()
  
  var body: some View {
    ZStack {
      if let image = vm.image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(width: 250, height: 250, alignment: .center)
      }
    }
    .onAppear { Task { await vm.fetchImage() } }
  }
}

struct DownloadImagesUsingAsyncAwait_Previews: PreviewProvider {
  static var previews: some View {
    DownloadImagesUsingAsyncAwait()
  }
}
