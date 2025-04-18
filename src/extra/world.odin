package core

import b2 "vendor:box2d"

import "core:fmt"
import "core:log"

MAX_STEPS :: 120
TIMESTEP :: 1.0 / FPS
SUBSTEP :: 4
NB_BODIES :: 10

World :: struct {
	world_id:  b2.WorldId,
	ground_id: b2.BodyId,
	//bodies:    [dynamic]Body,
	boxes:     #soa[dynamic]Box,
}

createWorld :: proc() -> (world: World) {
	world_def := b2.DefaultWorldDef()
	world_def.gravity = b2.Vec2{0, -10}
	world.world_id = b2.CreateWorld(world_def)
	world.ground_id = createGround(world.world_id)

	for body_idx in 0 ..< NB_BODIES {
		append_soa(&world.boxes, createBody(world.world_id, cast(f32)body_idx))
	}

	return world
}

releaseWorld :: proc(world: World) {
	for body in world.boxes {
		releaseBody(body)
	}
	delete(world.boxes)
	b2.DestroyBody(world.ground_id)
	b2.DestroyWorld(world.world_id)
}

GROUND_HALF_WIDTH :: 50
GROUND_HALF_HEIGHT :: 5

createGround :: proc(world_id: b2.WorldId) -> b2.BodyId {
	ground_def := b2.DefaultBodyDef()
	ground_def.position = b2.Vec2{0, -GROUND_HALF_HEIGHT}
	ground_id := b2.CreateBody(world_id, ground_def)
	_ = b2.CreatePolygonShape(
		ground_id,
		b2.DefaultShapeDef(),
		b2.MakeBox(GROUND_HALF_WIDTH, GROUND_HALF_HEIGHT),
	)

	return ground_id
}

Box :: struct {
	body_id:   b2.BodyId,
	shape_ids: [dynamic]b2.ShapeId,
}

createBody :: proc(world_id: b2.WorldId, pos_x: f32) -> (body: Box) {
	body_def := b2.DefaultBodyDef()
	body_def.type = b2.BodyType.dynamicBody
	body_def.position = b2.Vec2{pos_x, 10}
	body.body_id = b2.CreateBody(world_id, body_def)

	body_shape := b2.DefaultShapeDef()
	body_shape.density = 1.0
	body_shape.friction = 0.3

	//append(
	//   &body.shape_ids,
	//   b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeBox(1.25, 2.25)),
	//)
	append(&body.shape_ids, b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeSquare(1)))

	return body
}

releaseBody :: proc(body: Box) {
	log.debugf("releasing body %v", body)
	for shape_id in body.shape_ids {
		b2.DestroyShape(shape_id)
	}
	delete(body.shape_ids)
	b2.DestroyBody(body.body_id)
}

tick :: proc(world: World) {
	b2.World_Step(world.world_id, TIMESTEP, SUBSTEP)
}

generateMoreBodies :: proc(world: ^World) {
	append_soa(&world.boxes, createBody(world.world_id, 0))
}
