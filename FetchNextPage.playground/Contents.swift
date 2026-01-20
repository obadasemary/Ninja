/*
    Fetch Next Page Example
    
    This example demonstrates how to fetch paginated data asynchronously. The `viewModel` class contains a method `test` that continuously fetches the next page of data until there are no more pages left. The `fetchNextPage` function simulates an asynchronous network call to retrieve the next page.
*/

import UIKit

var greeting = "Hello, playground"

class viewModel {
    
    var hasMorePages = true
    
    func test() async {
        
        Task {

            hasMorePages = true
            while hasMorePages {
                let page = await fetchNextPage()
                hasMorePages = !page.isLastPage
            }
        }
    }
}



func fetchNextPage() async -> Page {
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    return Page(isLastPage: false)
}

struct Page {
    var isLastPage: Bool
}

