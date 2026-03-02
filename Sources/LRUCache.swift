import Foundation

/// Simple LRU (Least Recently Used) cache implementation
/// Thread-safe cache with automatic eviction when capacity is reached
final class LRUCache<Key: Hashable> {
    private var cache: [Key: Node]
    private var head: Node?
    private var tail: Node?
    private let capacity: Int
    private let lock = NSLock()
    
    private class Node {
        let key: Key
        var prev: Node?
        var next: Node?
        
        init(key: Key) {
            self.key = key
        }
    }
    
    init(capacity: Int) {
        self.capacity = max(1, capacity)
        self.cache = [:]
        self.cache.reserveCapacity(capacity)
    }
    
    /// Insert a key into the cache (marking it as most recently used)
    func insert(_ key: Key) {
        lock.lock()
        defer { lock.unlock() }
        
        // If already exists, move to front
        if let existingNode = cache[key] {
            moveToFront(existingNode)
            return
        }
        
        // Create new node
        let newNode = Node(key: key)
        cache[key] = newNode
        addToFront(newNode)
        
        // Evict least recently used if over capacity
        if cache.count > capacity {
            removeLRU()
        }
    }
    
    /// Check if key exists in cache
    func contains(_ key: Key) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let node = cache[key] else { return false }
        moveToFront(node)
        return true
    }
    
    /// Number of items in cache
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }
    
    /// Remove all items from cache
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        head = nil
        tail = nil
    }
    
    // MARK: - Private Helpers
    
    private func addToFront(_ node: Node) {
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
        if tail == nil {
            tail = node
        }
    }
    
    private func moveToFront(_ node: Node) {
        guard node !== head else { return }
        
        // Remove from current position
        node.prev?.next = node.next
        node.next?.prev = node.prev
        
        if node === tail {
            tail = node.prev
        }
        
        // Add to front
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
    }
    
    private func removeLRU() {
        guard let lruNode = tail else { return }
        
        cache.removeValue(forKey: lruNode.key)
        
        if lruNode === head {
            head = nil
            tail = nil
        } else {
            tail = lruNode.prev
            tail?.next = nil
        }
    }
}
