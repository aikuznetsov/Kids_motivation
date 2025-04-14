import SwiftUI

func drawArrow(from: CGPoint, to: CGPoint, in context: GraphicsContext) {
    let fromPoint = CGPoint(x: from.x, y: from.y + 70)
    let toPoint = CGPoint(x: to.x, y: to.y - 70)

    let controlPoint = CGPoint(
        x: (fromPoint.x + toPoint.x) / 2,
        y: min(fromPoint.y, toPoint.y) - 10
    )

    // Arrow path
    var path = Path()
    path.move(to: fromPoint)
    path.addQuadCurve(to: toPoint, control: controlPoint)

    // Arrowhead path
    let angle = atan2(toPoint.y - controlPoint.y, toPoint.x - controlPoint.x)
    let arrowLength: CGFloat = 16
    let arrowAngle: CGFloat = .pi / 6

    let point1 = CGPoint(
        x: toPoint.x - arrowLength * cos(angle - arrowAngle),
        y: toPoint.y - arrowLength * sin(angle - arrowAngle)
    )
    let point2 = CGPoint(
        x: toPoint.x - arrowLength * cos(angle + arrowAngle),
        y: toPoint.y - arrowLength * sin(angle + arrowAngle)
    )

    var arrowHead = Path()
    arrowHead.move(to: toPoint)
    arrowHead.addLine(to: point1)
    arrowHead.move(to: toPoint)
    arrowHead.addLine(to: point2)

    // BLACK contour (background)
    context.stroke(
        path,
        with: .color(.black),
        style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round)
    )
    context.stroke(
        arrowHead,
        with: .color(.black),
        style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round)
    )

    // RED foreground
    context.stroke(
        path,
        with: .color(.red),
        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
    )
    context.stroke(
        arrowHead,
        with: .color(.red),
        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
    )
}
