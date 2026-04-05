package sim_bodies

import b2 "vendor:box2d"

import "core:log"

BodyData :: struct {
	body_id:   b2.BodyId,
	shape_ids: [dynamic]b2.ShapeId,
}

CapsuleData :: struct {
	color: b2.HexColor,
}

Capsule :: struct {
	using body:   BodyData,
	capsule_data: CapsuleData,
}

createCapsule :: proc(world_id: b2.WorldId, pos: b2.Vec2, color: b2.HexColor) -> (body: Capsule) {
	body_def := b2.DefaultBodyDef()
	body_def.type = b2.BodyType.dynamicBody
	body_def.position = b2.Vec2{pos.x, pos.y}
	body.body_id = b2.CreateBody(world_id, body_def)
	body.capsule_data.color = color

	body_shape := b2.DefaultShapeDef()
	body_shape.density = 1.0

	body_surface := b2.DefaultSurfaceMaterial()
	body_surface.friction = 0.3
	body_shape.material = body_surface

	b2.Body_SetUserData(body.body_id, &body.capsule_data)

	append(&body.shape_ids, b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeSquare(.75)))
	append(&body.shape_ids, b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeSquare(1.25)))
	append(
		&body.shape_ids,
		b2.CreateCapsuleShape(body.body_id, body_shape, b2.Capsule{{-1, 0}, {1, 0}, 1}),
	)
	return
}

releaseCapsule :: proc(body: ^Capsule) {
	log.debugf("releasing capsule %v", body)
	// destroying the body destroys all shape associated
	//for shape_id in body.shape_ids {
	//   b2.DestroyShape(shape_id, true)
	//}
	delete(body.shape_ids)
	// b2.DestroyBody(body.body_id)
}
