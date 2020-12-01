//
//  Created by Dimitrios Chatzieleftheriou on 24/11/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

final class NetworkDataOperation: Operation {
    private var data: Data?
    private let proccessor: MetadataStreamSource

    var executionCompleted: ((Data) -> Void)?

    var proccessedData: Data?

    init(data: Data, proccessor: MetadataStreamSource) {
        // copy bytes so we don't work with volatile data from network
        self.data = data.withUnsafeBytes { pointer -> Data? in
            guard !data.isEmpty else { return nil }
            return Data(bytes: pointer.baseAddress!, count: pointer.count)
        }
        self.proccessor = proccessor
        super.init()
    }

    deinit {
        self.data = nil
        self.proccessedData = nil
        self.executionCompleted = nil
    }

    override func main() {
        guard !isCancelled else {
            self.data = nil
            return
        }
        guard let data = data else { return }
        if proccessor.canProccessMetadata {
            let extractedAudioData = proccessor.proccessMetadata(data: data)
            executionCompleted?(extractedAudioData)
        } else {
            executionCompleted?(data)
        }
        self.data = nil
    }
}
