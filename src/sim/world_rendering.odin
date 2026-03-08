package sim

import b2 "vendor:box2d"
import xray "vendor:raylib"

BODY_COLORS: [8]xray.Color = {
	xray.RED,
	xray.BLUE,
	xray.GREEN,
	xray.GOLD,
	xray.PURPLE,
	xray.ORANGE,
	xray.SKYBLUE,
	xray.RAYWHITE,
}

renderWorld :: proc(world: ^World) {
	drawBody(world.ground_id, bodyColor(0))

	color_idx := 1
	for body in world.bodies {
		drawBody(body.body_id, bodyColor(color_idx))
		color_idx += 1
	}
}

bodyColor :: proc(index: int) -> xray.Color {
	return BODY_COLORS[index % len(BODY_COLORS)]
}

drawBody :: proc(body_id: b2.BodyId, color: xray.Color) {
	transform := b2.Body_GetTransform(body_id)
	shape_count := b2.Body_GetShapeCount(body_id)
	shape_ids := make([]b2.ShapeId, shape_count, context.temp_allocator)

	_ = b2.Body_GetShapes(body_id, shape_ids)
	for shape_id in shape_ids {
		drawShape(shape_id, transform, color)
	}
}

drawShape :: proc(shape_id: b2.ShapeId, parent_transform: b2.Transform, color: xray.Color) {
	switch b2.Shape_GetType(shape_id) {
	case .polygonShape:
		polygon := b2.Shape_GetPolygon(shape_id)
		drawPolygonShape(parent_transform, polygon, color)
	case .capsuleShape:
		capsule := b2.Shape_GetCapsule(shape_id)
		drawCapsuleShape(parent_transform, capsule, color)
	case .circleShape:
		circle := b2.Shape_GetCircle(shape_id)
		drawCircleShape(parent_transform, circle, color)
	case .segmentShape:
		segment := b2.Shape_GetSegment(shape_id)
		drawSegmentShape(parent_transform, segment, color)
	case .chainSegmentShape:
		chain_segment := b2.Shape_GetChainSegment(shape_id)
		drawChainSegmentShape(parent_transform, chain_segment, color)
	}
}

drawPolygonShape :: proc(transform: b2.Transform, polygon: b2.Polygon, color: xray.Color) {
	for vertex_idx in 0 ..< polygon.count {
		start := b2.TransformPoint(transform, polygon.vertices[vertex_idx])
		end := b2.TransformPoint(transform, polygon.vertices[(vertex_idx + 1) % polygon.count])
		xray.DrawLineV(start, end, color)
	}
}

drawCapsuleShape :: proc(transform: b2.Transform, capsule: b2.Capsule, color: xray.Color) {
	c1 := b2.TransformPoint(transform, capsule.center1)
	c2 := b2.TransformPoint(transform, capsule.center2)

	xray.DrawLineV(c1, c2, color)
	xray.DrawCircleLinesV(c1, capsule.radius, color)
	xray.DrawCircleLinesV(c2, capsule.radius, color)
}

drawCircleShape :: proc(transform: b2.Transform, circle: b2.Circle, color: xray.Color) {
	center := b2.TransformPoint(transform, circle.center)
	xray.DrawCircleLinesV(center, circle.radius, color)
}

drawSegmentShape :: proc(transform: b2.Transform, segment: b2.Segment, color: xray.Color) {
	p1 := b2.TransformPoint(transform, segment.point1)
	p2 := b2.TransformPoint(transform, segment.point2)
	xray.DrawLineV(p1, p2, color)
}

drawChainSegmentShape :: proc(
	transform: b2.Transform,
	chain_segment: b2.ChainSegment,
	color: xray.Color,
) {
	p1 := b2.TransformPoint(transform, chain_segment.segment.point1)
	p2 := b2.TransformPoint(transform, chain_segment.segment.point2)
	xray.DrawLineV(p1, p2, color)
}
