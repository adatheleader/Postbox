import Foundation

public final class ItemCacheEntryId {
    public let collectionId: ItemCacheCollectionId
    public let key: ValueBoxKey
    
    public init(collectionId: ItemCacheCollectionId, key: ValueBoxKey) {
        self.collectionId = collectionId
        self.key = key
    }
}

private enum ItemCacheSection: Int8 {
    case items = 0
    case accessIndexToItemId = 1
    case itemIdToAccessIndex = 2
}

final class ItemCacheTable: Table {
    static func tableSpec(_ id: Int32) -> ValueBoxTable {
        return ValueBoxTable(id: id, keyType: .binary)
    }
    
    private func itemKey(id: ItemCacheEntryId) -> ValueBoxKey {
        let key = ValueBoxKey(length: 1 + 1 + id.key.length)
        key.setInt8(0, value: ItemCacheSection.items.rawValue)
        key.setInt8(1, value: id.collectionId)
        memcpy(key.memory.advanced(by: 2), id.key.memory, id.key.length)
        return key
    }
    
    private func itemIdToAccessIndexKey(id: ItemCacheEntryId) -> ValueBoxKey {
        let key = ValueBoxKey(length: 1 + 1 + id.key.length)
        key.setInt8(0, value: ItemCacheSection.accessIndexToItemId.rawValue)
        key.setInt8(1, value: id.collectionId)
        memcpy(key.memory.advanced(by: 2), id.key.memory, id.key.length)
        return key
    }
    
    private func accessIndexToItemId(collectionId: ItemCacheCollectionId, index: Int32) -> ValueBoxKey {
        let key = ValueBoxKey(length: 1 + 1 + 4)
        key.setInt8(0, value: ItemCacheSection.accessIndexToItemId.rawValue)
        key.setInt8(1, value: collectionId)
        key.setInt32(2, value: index)
        return key
    }
    
    func put(id: ItemCacheEntryId, entry: Coding, metaTable: ItemCacheMetaTable) {
        let encoder = Encoder()
        encoder.encodeRootObject(entry)
        self.valueBox.set(self.table, key: self.itemKey(id: id), value: encoder.readBufferNoCopy())
    }
    
    func retrieve(id: ItemCacheEntryId, metaTable: ItemCacheMetaTable) -> Coding? {
        if let value = self.valueBox.get(self.table, key: self.itemKey(id: id)), let entry = Decoder(buffer: value).decodeRootObject() {
            return entry
        }
        return nil
    }
    
    override func clearMemoryCache() {
        
    }
    
    override func beforeCommit() {
        
    }
}