import UIKit

var greeting = "Hello, playground"

class viewModel {
    
    var hasMorePages = true
    
    func test() async {
        
        Task { [weak self] in

            self?.hasMorePages = true
            while hasMorePages {
                guard let self else { return }
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

