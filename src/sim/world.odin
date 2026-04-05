package sim

import b2 "vendor:box2d"

import "core:log"
import "core:math/rand"

MAX_STEPS :: 120
TIMESTEP :: 1.0 / FPS
SUBSTEP :: 4
NB_BODIES :: 10

BODY_COLORS: [8]b2.HexColor = {
	b2.HexColor.Red,
	b2.HexColor.Blue,
	b2.HexColor.Green,
	b2.HexColor.Gold,
	b2.HexColor.Purple,
	b2.HexColor.Orange,
	b2.HexColor.SkyBlue,
	b2.HexColor.White,
}

World :: struct {
	world_id:  b2.WorldId,
	ground_id: b2.BodyId,
	bodies:    [dynamic]Body,
}

initialPosition :: proc() -> (initial_position: b2.Vec2) {
   randomAround :: proc(center, delta: int) -> f32 {                            
      return cast(f32)(rand.int_max(delta * 2 + 1) - delta + center)            
   }                                                                            
	INITIAL_POS_X :: 0
	INITIAL_POS_DX :: 5
	initial_position.x = randomAround(INITIAL_POS_X, INITIAL_POS_DX)
	INITIAL_POS_Y :: 10
	INITIAL_POS_DY :: 5
	initial_position.y = randomAround(INITIAL_POS_Y, INITIAL_POS_DY)
	return
}

createWorld :: proc() -> (world: World) {
	world_def := b2.DefaultWorldDef()
	world_def.gravity = b2.Vec2{0, -10}
	world.world_id = b2.CreateWorld(world_def)
	world.ground_id = createGround(world.world_id)

	for body_idx in 0 ..< NB_BODIES {
		append(
			&world.bodies,
			createBody(
				world.world_id,
				initialPosition(),
				BODY_COLORS[body_idx % len(BODY_COLORS)],
			),
		)
	}
	return world
}

releaseWorld :: proc(world: World) {
	for body in world.bodies {
		releaseBody(body)
	}
	delete(world.bodies)
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

Body :: struct {
	body_id:   b2.BodyId,
	shape_ids: [dynamic]b2.ShapeId,
	color:     b2.HexColor,
}

createBody :: proc(world_id: b2.WorldId, pos: b2.Vec2, color: b2.HexColor) -> (body: Body) {
	body_def := b2.DefaultBodyDef()
	body_def.type = b2.BodyType.dynamicBody
	body_def.position = b2.Vec2{pos.x, pos.y}
	body.body_id = b2.CreateBody(world_id, body_def)
	body.color = color

	body_shape := b2.DefaultShapeDef()
	body_shape.density = 1.0

	body_surface := b2.DefaultSurfaceMaterial()
	body_surface.friction = 0.3
	body_shape.material = body_surface

	append(&body.shape_ids, b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeSquare(.75)))
	append(&body.shape_ids, b2.CreatePolygonShape(body.body_id, body_shape, b2.MakeSquare(1.25)))
	append(
		&body.shape_ids,
		b2.CreateCapsuleShape(body.body_id, body_shape, b2.Capsule{{-1, 0}, {1, 0}, 1}),
	)

	return body
}

releaseBody :: proc(body: Body) {
	log.debugf("releasing body %v", body)
	// destroying the body destroys all shape associated
	//for shape_id in body.shape_ids {
	//   b2.DestroyShape(shape_id, true)
	//}
	delete(body.shape_ids)
	b2.DestroyBody(body.body_id)
}

tick :: proc(world: World) {
	b2.World_Step(world.world_id, TIMESTEP, SUBSTEP)
}

generateMoreBodies :: proc(world: ^World) {
	color_idx := len(world.bodies) % len(BODY_COLORS)
	append(&world.bodies, createBody(world.world_id, initialPosition(), BODY_COLORS[color_idx]))
}
