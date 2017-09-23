////
////  TaskFlow.swift
////  TaskFlow
////
////  Created by Bernardo Breder on 10/02/17.
////
////
//
//import Foundation
//import Dispatch
//
//#if SWIFT_PACKAGE
//    import AtomicValue
//#endif
//
//public class TaskFlowManager {
//    
//    let queue = OperationQueue()
//    
//    public init() {
//        queue.maxConcurrentOperationCount = 1
//    }
//    
//    @discardableResult
//    public func execute(title: String, _ function: @escaping (TaskFlow) -> Void) -> TaskFlow {
//        return TaskFlow(taskFlowManager: self, undoTitle: title, function).apply()
//    }
//    
//    public func main(_ function: @escaping (TaskFlowManager) -> Void) {
//        DispatchQueue.main.async { function(self) }
//    }
//    
//}
//
//// Struct ou Classe
//public class TaskFlow {
//    
//    weak var taskFlowManager: TaskFlowManager?
//    
//    let function: (TaskFlow) -> Void
//    
//    let lock = Lock()
//    
//    var tasks: [TaskFlowItem] = []
//    
//    var _cancelled = AtomicBool(false)
//    
//    public init(taskFlowManager: TaskFlowManager, undoTitle: String, _ function: @escaping (TaskFlow) -> Void) {
//        self.taskFlowManager = taskFlowManager
//        self.function = function
//    }
//    
//    @discardableResult
//    public func apply() -> Self {
//        self.dispatchAtUtility {
//            self._cancelled.set(false)
//            self.dispatchAtMainSync {
//                self.function(self)
//            }
//            guard !self._cancelled.get() else { return }
//            do {
//                for task in self.tasks {
//                    try task.apply()
//                    guard !self._cancelled.get() else { throw TaskFlowError.interrupt }
//                }
//            } catch {
//            }
//        }
//        return self
//    }
//    
//    public func revert(_ function: @escaping () -> Void) {
//        self.reverts.append(TaskFlowItem.init(text: "", weight: 0, apply: {}, revert: {
//            self.dispatchAtMainAsync(function)
//        }))
//    }
//    
//    @discardableResult
//    public func revert() -> Self {
//        _cancelled.set(true)
//        if _success.get() {
//            self.dispatchAtUtility {
//                for task in self.reverts.reversed() {
//                    task.revert()
//                    self.processChangeUI(delta: -task.weight)
//                }
//            }
//        }
//        return self
//    }
//    
//    public func main<T>(query: @escaping () throws -> T) rethrows -> T {
//        return try DispatchQueue.main.sync(execute: query)
//    }
//    
//    public func task(_ task: TaskFlowItem) {
//        self.tasks.append(task)
//    }
//    
//    public var cancelled: Bool {
//        return _cancelled.get()
//    }
//    
//    public func cancel() {
//        _cancelled.set(true)
//    }
//    
//    private func processChangeUI(delta: Int64) {
//        self.dispatchAtMainAsync {
//            self.progress.completedUnitCount += delta
//            self.processChangedCallback?()
//        }
//    }
//    
//    private func dispatchAtUtility(_ function: @escaping () -> Void) {
//        taskFlowManager.queue.addOperation { autoreleasepool { function() } }
//    }
//    
//    private func dispatchAtMainAsync(_ function: @escaping () -> Void) {
//        DispatchQueue.main.async { autoreleasepool { function() } }
//    }
//    
//    private func dispatchAtMainSync(_ function: @escaping () -> Void) {
//        DispatchQueue.main.sync { autoreleasepool { function() } }
//    }
//    
//}
//
//public struct TaskFlowItem {
//    
//    public let text: String
//    
//    public let weight: Int64
//    
//    public let apply: () throws -> Void
//    
//    public let revert: () -> Void
//    
//}
//
//public enum TaskFlowError: Error {
//    case interrupt
//}
//
//public protocol TaskFlowProgress: NSObjectProtocol {
//    
//    func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64)
//    
//    var totalUnitCount: Int64 { get set }
//    
//    var completedUnitCount: Int64 { get set }
//    
//}
//
//public protocol TaskFlowUndoManager: NSObjectProtocol {
//    
//    func registerUndo(_ handler: @escaping () -> Void)
//    
//    func setActionName(_ title: String)
//    
//}
//
//public class EmptyTaskFlowUndoManager: NSObject, TaskFlowUndoManager {
//
//    public func registerUndo(_ handler: @escaping () -> Void) {}
//    
//    public func setActionName(_ title: String) {}
//    
//}
