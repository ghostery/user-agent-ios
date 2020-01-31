protocol DefaultConstructable {
    init()
}

protocol ConstructableWithSettings {
    associatedtype Settings
    init(settings: Settings)
}
