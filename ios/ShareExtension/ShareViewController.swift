import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        handleInputItems()
    }

    private func handleInputItems() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }

        let groupId = "group.com.lumi.shared"
        let defaults = UserDefaults(suiteName: groupId)

        for item in items {
            if let attachments = item.attachments {
                for provider in attachments {
                    if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                        provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (data, error) in
                            if let text = data as? String {
                                defaults?.set(text, forKey: "last_shared_text")
                            }
                            self.completeRequest()
                        }
                        return
                    }

                    if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { (data, error) in
                            var imageData: Data? = nil
                            if let url = data as? URL {
                                imageData = try? Data(contentsOf: url)
                            } else if let img = data as? UIImage {
                                imageData = img.jpegData(compressionQuality: 0.9)
                            }

                            if let d = imageData, let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) {
                                let dest = container.appendingPathComponent("shared_receipt.jpg")
                                try? d.write(to: dest)
                                defaults?.set(dest.lastPathComponent, forKey: "last_shared_image")
                            }
                            self.completeRequest()
                        }
                        return
                    }

                    // Fallback: load as data
                    provider.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil) { (data, error) in
                        if let url = data as? URL, let d = try? Data(contentsOf: url) {
                            if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) {
                                let dest = container.appendingPathComponent(url.lastPathComponent)
                                try? d.write(to: dest)
                                defaults?.set(dest.lastPathComponent, forKey: "last_shared_file")
                            }
                        }
                        self.completeRequest()
                    }
                }
            }
        }
        // nothing handled
        completeRequest()
    }

    private func completeRequest() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
