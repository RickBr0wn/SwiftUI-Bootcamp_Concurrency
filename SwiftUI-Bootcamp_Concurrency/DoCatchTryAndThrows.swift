//
//  doTryCatchAndThrows.swift
//  SwiftUI-Bootcamp
//
//  Created by Rick Brown on 03/07/2022.
//

import SwiftUI

class DoTryCatchAndThrowsDataManager {
  let isActive: Bool = true
  
  public func getTitle() -> (title: String?, error: Error?) {
    return isActive ? ("New text!", nil) : (nil, URLError(.badURL))
  }
  
  public func getTitleWithResult() -> Result<String, Error> {
    return isActive ?
      .success("New text with Result") :
      .failure(URLError(.badURL))
  }
  
  public func getTitleWithDoCatch() throws -> String {
    if isActive {
      return "New text!"
    } else {
      throw URLError(.badURL)
    }
  }
  
  public func anotherGetTitleWithDoCatch() throws -> String {
    if isActive {
      return "Another new text!"
    } else {
      throw URLError(.badURL)
    }
  }
  
  public func alwaysThrowsAnError() throws -> String {
    throw URLError(.badURL)
  }
}

class DoTryCatchAndThrowsViewModel: ObservableObject {
  @Published var text: String = "Starting Text"
  let manager = DoTryCatchAndThrowsDataManager()
  
  public func fetchTitle() -> Void {
    /* Using getTitle()
     
     let returnedValue = manager.getTitle()
     
     if let newTitle = returnedValue.title {
     self.text = newTitle
     } else if let error = returnedValue.error {
     self.text = error.localizedDescription
     }
     */
    
    /* Using getTitleWithResult()
     
     let result = manager.getTitleWithResult()
     
     switch result {
     case .success(let newTitle):
     self.text = newTitle
     case .failure(let error):
     self.text = error.localizedDescription
     }
     */
    
    /// Using try optionally, having to process the .failure()
    /// Can be used outside of do/catch blocks
    let newTitle = try? manager.alwaysThrowsAnError()
    if let newTitle = newTitle {
      self.text = newTitle
    }
    
    do {
      /// Using optional try here negates the code jumping straight to the catch block
      let newTitle = try? manager.alwaysThrowsAnError()
      if let newTitle = newTitle {
        self.text = newTitle
      }
      
      let anotherTitle = try manager.anotherGetTitleWithDoCatch()
      self.text = anotherTitle
    } catch {
      self.text = error.localizedDescription
    }
    
  }
}

struct DoTryCatchAndThrows: View {
  @StateObject private var vm = DoTryCatchAndThrowsViewModel()
  
  var body: some View {
    Text(vm.text)
      .frame(width: 300, height: 300, alignment: .center)
      .background(Color.blue)
      .font(.title)
      .onTapGesture { vm.fetchTitle() }
  }
}

struct DoTryCatchAndThrows_Previews: PreviewProvider {
  static var previews: some View {
    DoTryCatchAndThrows()
  }
}
