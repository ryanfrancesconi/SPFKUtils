import Foundation

// MARK: Only here to provide a non sendable version of the OTAtomics propertyWrapper

@propertyWrapper
public final class ThreadSafe<T> {
    @inline(__always)
    private var value: T

    @inline(__always)
    private let lock = RWThreadLock()

    @inline(__always)
    public init(wrappedValue value: T) {
        self.value = value
    }

    @inline(__always)
    public var wrappedValue: T {
        get {
            lock.readLock()
            defer { self.lock.unlock() }
            return value
        }

        set {
            lock.writeLock()
            value = newValue
            lock.unlock()
        }

        // _modify { } is an internal Swift computed setter, similar to set { }
        // however it gives in-place exclusive mutable access
        // which allows get-then-set operations such as collection subscripts
        // to be performed in a single thread-locked operation
        _modify {
            self.lock.writeLock()
            yield &value
            self.lock.unlock()
        }
    }
}

fileprivate final class RWThreadLock: ThreadLock {
    @inline(__always)
    private var lock = pthread_rwlock_t()

    @inline(__always)
    init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            preconditionFailure("Unable to initialize the lock")
        }
    }

    @inline(__always)
    deinit {
        pthread_rwlock_destroy(&lock)
    }

    @inline(__always)
    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }

    @inline(__always)
    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }

    @inline(__always)
    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
}

fileprivate protocol ThreadLock {
    init()

    /// Lock a resource for writing. So only one thing can write, and nothing else can read or write.
    func writeLock()

    /// Lock a resource for reading. Other things can also lock for reading at the same time, but nothing else can write at that time.
    func readLock()

    /// Unlock a resource
    func unlock()
}
