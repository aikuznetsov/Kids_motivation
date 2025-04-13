
import SwiftUI

func drawArrow(from: CGPoint, to: CGPoint, in context: GraphicsContext) {
    let fromPoint = CGPoint(x: from.x, y: from.y + 70)
    let toPoint = CGPoint(x: to.x, y: to.y - 70)

    let controlPoint = CGPoint(
        x: (fromPoint.x + toPoint.x) / 2,
        y: min(fromPoint.y, toPoint.y) - 10
    )

    var path = Path()
    path.move(to: fromPoint)
    path.addQuadCurve(to: toPoint, control: controlPoint)

    context.stroke(path, with: .color(.red), lineWidth: 4)

    // Draw arrowhead
    let angle = atan2(toPoint.y - controlPoint.y, toPoint.x - controlPoint.x)
    let arrowLength: CGFloat = 10
    let arrowAngle: CGFloat = .pi / 6

    let point1 = CGPoint(
        x: toPoint.x - arrowLength * cos(angle - arrowAngle),
        y: toPoint.y - arrowLength * sin(angle - arrowAngle)
    )
    let point2 = CGPoint(
        x: toPoint.x - arrowLength * cos(angle + arrowAngle),
        y: toPoint.y - arrowLength * sin(angle + arrowAngle)
    )

    var arrowPath = Path()
    arrowPath.move(to: toPoint)
    arrowPath.addLine(to: point1)
    arrowPath.move(to: toPoint)
    arrowPath.addLine(to: point2)

    context.stroke(arrowPath, with: .color(.red), lineWidth: 4)
}

