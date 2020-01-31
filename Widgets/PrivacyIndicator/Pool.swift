import UIKit

extension PrivacyIndicator {

class Pool<T: ConstructableWithSettings>
        where T.Settings: DefaultConstructable {
    var settings: T.Settings = T.Settings()
    private var pool: [T] = []
    private var current: Int = 0

    func reallocate(with n: Int) {
        print("XXXX Pool reallocate # n", self.pool.count, n)
        self.current = 0
        if n < self.pool.count {
            self.pool = Array(self.pool[0..<n])
        } else {
            let range = self.pool.count..<n
            range.forEach { _ in self.pool.append(T(settings: self.settings)) }
        }
    }
    func next() -> T {
        print("XXXX Pool next", self.current)
        assert(self.current < self.pool.count)
        let tmp = self.current
        self.current += 1
        return self.pool[tmp]
    }
}
    
class Strike: ConstructableWithSettings {
    struct Shape: DefaultConstructable {
        var start: CGPoint = CGPoint()
        var end: CGPoint = CGPoint()
        var lineWidth: CGFloat = 0
    }
    typealias Settings = Shape
    var layer: CAShapeLayer
    required init(settings: Strike.Shape) {
        print("XXXX Strike init")
        self.layer = PrivacyIndicator.utils.createStrike(
            start: settings.start,
            end: settings.end,
            lineWidth: settings.lineWidth
        )
    }
    deinit {
        print("XXXX Strike deinit")
        self.layer.removeFromSuperlayer()
    }
}

class Circle: ConstructableWithSettings {
    struct Shape: DefaultConstructable {
        var center: CGPoint = CGPoint()
        var radius: CGFloat = 0
        var lineWidth: CGFloat = 0
    }
    typealias Settings = Shape
    var layer: CAShapeLayer
    required init(settings: Circle.Shape) {
        print("XXXX Circle init")
        self.layer = PrivacyIndicator.utils.createCircle(
            center: settings.center,
            radius: settings.radius,
            lineWidth: settings.lineWidth
        )
    }
    deinit {
        print("XXXX Circle deinit")
        self.layer.removeFromSuperlayer()
    }
}
}
