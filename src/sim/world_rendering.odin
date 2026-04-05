package sim

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "bodies"

renderWorld :: proc(world: ^World) {
	drawGround(world.ground_id, hex_2_rgb(b2.HexColor.Gray))
	for body in world.bodies {
		drawBody(body)
	}
}

drawGround :: proc(ground_id: b2.BodyId, color: xray.Color) {
	transform, shape_ids := extractBodyData(ground_id)
	for shape_id in shape_ids {
		drawShape(shape_id, transform, color)
	}
}

extractBodyData :: proc(body_id: b2.BodyId, allocator := context.temp_allocator) -> (b2.Transform, []b2.ShapeId) {
	transform := b2.Body_GetTransform(body_id)
	shape_count := b2.Body_GetShapeCount(body_id)
	shape_ids := make([]b2.ShapeId, shape_count, allocator)
	return transform, b2.Body_GetShapes(body_id, shape_ids)
}

drawBody :: proc(body: Body) {
	switch b in body {
	case bodies.Capsule:
		drawCapsule(b)
	}
}

drawCapsule :: proc(capsule: bodies.Capsule) {
	transform, shape_ids := extractBodyData(capsule.body_id)
	for shape_id in shape_ids {
		drawShape(shape_id, transform, hex_2_rgb(capsule.capsule_data.color))
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
