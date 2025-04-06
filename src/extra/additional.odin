package extra

import "vendor:box2d"

import "core:fmt"
import "core:log"

MAX_STEPS :: 120
TIMESTEP :: 1.0 / 60.0
SUBSTEP :: 4
NB_BODIES :: 4

Body :: struct {
	body_id:  box2d.BodyId,
	shape_id: box2d.ShapeId,
}

createBody :: proc(world_id: box2d.WorldId, pos_x: f32) -> (body: Body) {
	body_def := box2d.DefaultBodyDef()
	body_def.type = box2d.BodyType.dynamicBody
	body_def.position = box2d.Vec2{pos_x, 4}
	//body_id := box2d.CreateBody(world_id, body_def)
	body.body_id = box2d.CreateBody(world_id, body_def)

	body_shape := box2d.DefaultShapeDef()
	body_shape.density = 1.0
	body_shape.friction = 0.3
	//body_box := box2d.MakeBox(1,1)
	//body_shape_id := box2d.CreatePolygonShape(body_id, body_shape, box2d.MakeBox(1, 1))
	body.shape_id = box2d.CreatePolygonShape(body.body_id, body_shape, box2d.MakeBox(1, 1))
	return body
}

physx :: proc() {
	world_def := box2d.DefaultWorldDef()
	world_def.gravity = box2d.Vec2{0, -10}
	world_id := box2d.CreateWorld(world_def)
	defer box2d.DestroyWorld(world_id)

	ground_def := box2d.DefaultBodyDef()
	ground_def.position = box2d.Vec2{0, -10}
	ground_id := box2d.CreateBody(world_id, ground_def)
	//ground_box := box2d.MakeBox(50,10)
	//ground_shape := box2d.DefaultShapeDef()
	ground_shape_id := box2d.CreatePolygonShape(
		ground_id,
		box2d.DefaultShapeDef(),
		box2d.MakeBox(50, 10),
	)

	bodies: #soa[NB_BODIES]Body
	for body_idx in 0 ..< NB_BODIES {
		bodies[body_idx] = createBody(world_id, cast(f32)body_idx)
	}

	for i in 1 ..= MAX_STEPS {
		box2d.World_Step(world_id, TIMESTEP, SUBSTEP)

		for &body in bodies {
			angle := box2d.Rot_GetAngle(box2d.Body_GetRotation(body.body_id))
			log.debugf(
				"body %v: %v, %v",
				body.body_id.index1,
				box2d.Body_GetPosition(body.body_id),
				angle,
			)
		}
		log.info(world_id)
		//fmt.println(world_id)
	}
}
