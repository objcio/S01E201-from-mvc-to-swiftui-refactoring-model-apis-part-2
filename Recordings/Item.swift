import Foundation

class Item: Identifiable, ObservableObject {
	let uuid: UUID
	@Published private(set) var name: String
	weak var store: Store?
	weak var parent: Folder? {
        willSet {
            objectWillChange.send()
        }
		didSet {
			store = parent?.store
		}
	}
    
    var id: UUID { uuid }
    
	init(name: String, uuid: UUID) {
		self.name = name
		self.uuid = uuid
		self.store = nil
	}
	
	func setName(_ newName: String) {
		name = newName
		if let p = parent {
            p.reSort(changedItem: self)
			store?.save()
		}
	}
	
	func deleted() {
		parent = nil
	}
	
	var uuidPath: [UUID] {
		var path = parent?.uuidPath ?? []
		path.append(uuid)
		return path
	}
	
	func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
		guard let first = path.first, first == uuid else { return nil }
		return self
	}
}
