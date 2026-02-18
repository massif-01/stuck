import CoreGraphics

/// 路径引擎：根据路径类型生成目标点序列，与动作解耦
struct PathEngine {

    let bounds: CGRect

    init(bounds: CGRect) {
        self.bounds = bounds
    }

    /// 为给定路径类型生成从当前位置出发的路径点
    func generatePath(
        type: PathType,
        from start: CGPoint,
        direction: CGFloat,
        segmentCount: Int = 8
    ) -> [CGPoint] {
        switch type {
        case .straight:
            return straightPath(from: start, direction: direction)
        case .rightAngle:
            return rightAnglePath(from: start)
        case .arc:
            return arcPath(from: start, direction: direction)
        case .sCurve:
            return sCurvePath(from: start, direction: direction)
        case .alongEdge:
            return alongEdgePath(from: start)
        case .randomDrift:
            return randomDriftPath(from: start)
        case .centerBounce:
            return centerBouncePath(from: start)
        case .fullScreenChaos:
            return fullScreenChaosPath(from: start)
        case .fixedPendulum:
            return fixedPendulumPath(from: start)
        case .diagonal:
            return diagonalPath(from: start, direction: direction)
        case .clockwiseEdge:
            return clockwiseEdgePath(from: start)
        case .burst:
            return burstPath(from: start, direction: direction)
        case .curve:
            return curvePath(from: start, direction: direction)
        case .sprint:
            return sprintPath(from: start, direction: direction)
        case .upperHalfJump:
            return upperHalfPath(from: start)
        case .spiral:
            return spiralPath(from: start)
        }
    }

    private func straightPath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let length: CGFloat = min(bounds.width, bounds.height) * 0.3
        let end = CGPoint(
            x: start.x + cos(direction) * length,
            y: start.y + sin(direction) * length
        )
        return interpolate(from: start, to: clamp(end), steps: 5)
    }

    private func rightAnglePath(from start: CGPoint) -> [CGPoint] {
        let corner = CGPoint(
            x: start.x + (start.x < bounds.midX ? 50 : -50),
            y: start.y + (start.y < bounds.midY ? 40 : -40)
        )
        let end = CGPoint(
            x: clamp(corner).x,
            y: corner.y + (corner.y < bounds.midY ? 30 : -30)
        )
        return [start] + interpolate(from: clamp(corner), to: clamp(end), steps: 3)
    }

    private func arcPath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let radius: CGFloat = 40
        let angleStep: CGFloat = .pi / 6
        var points = [start]
        var a = direction
        for _ in 0..<5 {
            a += angleStep
            let next = CGPoint(
                x: start.x + cos(a) * radius,
                y: start.y + sin(a) * radius
            )
            points.append(clamp(next))
        }
        return points
    }

    private func sCurvePath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let c1 = CGPoint(x: start.x + 30, y: start.y + 20)
        let c2 = CGPoint(x: start.x + 60, y: start.y - 10)
        let end = CGPoint(x: start.x + 80, y: start.y + 15)
        return interpolate(from: start, to: clamp(c1), steps: 2) +
            interpolate(from: clamp(c1), to: clamp(c2), steps: 2) +
            interpolate(from: clamp(c2), to: clamp(end), steps: 2)
    }

    private func alongEdgePath(from start: CGPoint) -> [CGPoint] {
        let margin: CGFloat = 30
        let pts: [CGPoint] = [
            CGPoint(x: bounds.minX + margin, y: bounds.maxY - margin),
            CGPoint(x: bounds.maxX - margin, y: bounds.maxY - margin),
            CGPoint(x: bounds.maxX - margin, y: bounds.minY + margin),
            CGPoint(x: bounds.minX + margin, y: bounds.minY + margin)
        ]
        guard let idx = pts.enumerated().min(by: { start.distance(to: $0.1) < start.distance(to: $1.1) })?.offset else { return [start] }
        var result = [start]
        for i in 1...4 {
            result.append(pts[(idx + i) % pts.count])
        }
        return result
    }

    private func randomDriftPath(from start: CGPoint) -> [CGPoint] {
        var pts = [start]
        var p = start
        for _ in 0..<4 {
            p = CGPoint(
                x: p.x + CGFloat.random(in: -25...25),
                y: p.y + CGFloat.random(in: -25...25)
            )
            pts.append(clamp(p))
        }
        return pts
    }

    private func centerBouncePath(from start: CGPoint) -> [CGPoint] {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let toCenter = interpolate(from: start, to: center, steps: 3)
        let away = CGPoint(
            x: center.x + (center.x - start.x) * 0.5,
            y: center.y + (center.y - start.y) * 0.5
        )
        return toCenter + interpolate(from: center, to: clamp(away), steps: 2)
    }

    private func fullScreenChaosPath(from start: CGPoint) -> [CGPoint] {
        let margin: CGFloat = 60
        var pts = [start]
        for _ in 0..<3 {
            let next = CGPoint(
                x: CGFloat.random(in: bounds.minX + margin...bounds.maxX - margin),
                y: CGFloat.random(in: bounds.minY + margin...bounds.maxY - margin)
            )
            pts.append(next)
        }
        return pts
    }

    private func fixedPendulumPath(from start: CGPoint) -> [CGPoint] {
        let left = CGPoint(x: bounds.minX + 50, y: start.y)
        let right = CGPoint(x: bounds.maxX - 50, y: start.y)
        return [start, left, right, left]
    }

    private func diagonalPath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let length: CGFloat = 80
        let end = CGPoint(
            x: start.x + cos(direction) * length,
            y: start.y + sin(direction) * length
        )
        return interpolate(from: start, to: clamp(end), steps: 6)
    }

    private func clockwiseEdgePath(from start: CGPoint) -> [CGPoint] {
        let margin: CGFloat = 40
        return [
            CGPoint(x: bounds.maxX - margin, y: bounds.maxY - margin),
            CGPoint(x: bounds.minX + margin, y: bounds.maxY - margin),
            CGPoint(x: bounds.minX + margin, y: bounds.minY + margin),
            CGPoint(x: bounds.maxX - margin, y: bounds.minY + margin),
            CGPoint(x: bounds.maxX - margin, y: bounds.maxY - margin)
        ]
    }

    private func burstPath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let length: CGFloat = min(bounds.width, bounds.height) * 0.4
        let end = CGPoint(
            x: start.x + cos(direction) * length,
            y: start.y + sin(direction) * length
        )
        return [start, clamp(end)]
    }

    private func curvePath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        var pts = [start]
        var a = direction
        for i in 0..<6 {
            a += CGFloat(i % 2 == 0 ? 1 : -1) * .pi / 8
            let next = CGPoint(
                x: start.x + cos(a) * 35 * CGFloat(i + 1),
                y: start.y + sin(a) * 35 * CGFloat(i + 1)
            )
            pts.append(clamp(next))
        }
        return pts
    }

    private func sprintPath(from start: CGPoint, direction: CGFloat) -> [CGPoint] {
        let length: CGFloat = min(bounds.width, bounds.height) * 0.5
        let end = CGPoint(
            x: start.x + cos(direction) * length,
            y: start.y + sin(direction) * length
        )
        return interpolate(from: start, to: clamp(end), steps: 4)
    }

    private func upperHalfPath(from start: CGPoint) -> [CGPoint] {
        let top = bounds.maxY - 80
        let xs: [CGFloat] = [
            bounds.midX - 40,
            bounds.midX + 40,
            bounds.midX - 30,
            bounds.midX + 30
        ]
        return [start] + xs.map { CGPoint(x: $0, y: top) }
    }

    private func spiralPath(from start: CGPoint) -> [CGPoint] {
        var pts = [start]
        for i in 1...6 {
            let angle = CGFloat(i) * .pi / 4
            let r = CGFloat(i) * 15
            pts.append(clamp(CGPoint(
                x: start.x + cos(angle) * r,
                y: start.y + sin(angle) * r
            )))
        }
        return pts
    }

    private func interpolate(from a: CGPoint, to b: CGPoint, steps: Int) -> [CGPoint] {
        guard steps > 0 else { return [b] }
        return (1...steps).map { i in
            let t = CGFloat(i) / CGFloat(steps)
            return CGPoint(
                x: a.x + (b.x - a.x) * t,
                y: a.y + (b.y - a.y) * t
            )
        }
    }

    private func clamp(_ p: CGPoint) -> CGPoint {
        let margin: CGFloat = 40
        return CGPoint(
            x: min(max(p.x, bounds.minX + margin), bounds.maxX - margin),
            y: min(max(p.y, bounds.minY + margin), bounds.maxY - margin)
        )
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
