import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    private static func makeModel() -> NSManagedObjectModel {
        // Define attributes
        let typeAttr = NSAttributeDescription()
        typeAttr.name = "type"
        typeAttr.attributeType = .stringAttributeType
        typeAttr.isOptional = false
        
        let contentAttr = NSAttributeDescription()
        contentAttr.name = "content"
        contentAttr.attributeType = .stringAttributeType
        contentAttr.isOptional = true
        
        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false
        
        let identifierAttr = NSAttributeDescription()
        identifierAttr.name = "identifier"
        identifierAttr.attributeType = .stringAttributeType
        identifierAttr.isOptional = false
        
        // Define entity
        let entity = NSEntityDescription()
        entity.name = "ClipboardItemEntity"
        entity.managedObjectClassName = String(describing: ClipboardItemEntity.self)
        entity.properties = [typeAttr, contentAttr, timestampAttr, identifierAttr]
        
        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let model = CoreDataManager.makeModel()
        let container = NSPersistentContainer(name: "ClipStackDataModel", managedObjectModel: model)
        
        // Configure the store description
        let description = NSPersistentStoreDescription()
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}