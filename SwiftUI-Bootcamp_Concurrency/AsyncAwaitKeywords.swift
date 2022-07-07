//
//  AsyncAwaitKeywords.swift
//  SwiftUI-Bootcamp_Concurrency
//
//  Created by Rick Brown on 04/07/2022.
//

import SwiftUI

class AsyncAwaitKeywordsViewModel: ObservableObject {
  @Published var dataArray: Array<String> = []
  
  /*
   public func addTitle() -> Void {
   DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
   self.dataArray.append("Title #1: \(Thread.current)")
   }
   }
   */
  
  /*
   public func addTitleTwo() -> Void {
   DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
   let title = "Title #2: \(Thread.current)"
   DispatchQueue.main.async {
   self.dataArray.append(title)
   }
   }
   }
   */
  
  public func addAuthorOne() async -> Void {
    let authorOne = "Author #1 : \(Thread.current)"
    // main thread
    self.dataArray.append(authorOne)
    // this Task will move onto a background thread
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    // background threads
    let authorTwo  = "Author #2 : \(Thread.current)"
    let authorThree  = "Author #3 : \(Thread.current)"
    let authorFour  = "Author #4 : \(Thread.current)"
    // always move back to main thread before updating UI 
    await MainActor.run(body: {
      self.dataArray.append(authorTwo)
      self.dataArray.append(authorThree)
      self.dataArray.append(authorFour)
      
      let authorThree  = "Author #3 : \(Thread.current)"
      self.dataArray.append(authorThree)
    })
  }
}

struct AsyncAwaitKeywords: View {
  @StateObject private var vm = AsyncAwaitKeywordsViewModel()
  
  var body: some View {
    List {
      ForEach(vm.dataArray, id: \.self) { data in
        Text(data)
      }
    }
    .onAppear {
      // vm.addTitle()
      // vm.addTitleTwo()
      Task {
        await vm.addAuthorOne()
      }
    }
  }
}

struct AsyncAwaitKeywords_Previews: PreviewProvider {
  static var previews: some View {
    AsyncAwaitKeywords()
  }
}
