package core

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "core:fmt"
import "core:log"

convertWorldCoordinates :: proc(coord: b2.Vec2) -> (result: xray.Vector2) {
	result.x = coord.x * PIXELS_PER_METER
	result.y = (WINDOW_HEIGHT - 10) - coord.y * PIXELS_PER_METER
	return
}

renderBox :: proc(box: Box) {
	position := b2.Body_GetPosition(box.body_id)
	coord := convertWorldCoordinates(position)
	radius := 1 * PIXELS_PER_METER
	xray.DrawCircle(cast(i32)coord.x, cast(i32)coord.y, cast(f32)radius, xray.PURPLE)
	log.debugf("rendering box at %v", coord)
}

renderGround :: proc(world: World) {
	//center := b2.Body_GetPosition(world.ground_id)
	center := b2.Body_GetWorldCenterOfMass(world.ground_id)
	top_left_corner := b2.Vec2{center.x - GROUND_HALF_WIDTH, center.y + GROUND_HALF_HEIGHT}
	coord := convertWorldCoordinates(top_left_corner)
	ground_width := 2 * GROUND_HALF_WIDTH * PIXELS_PER_METER
	ground_height := 2 * GROUND_HALF_HEIGHT * PIXELS_PER_METER
	xray.DrawRectangle(
		cast(i32)coord.x,
		cast(i32)coord.y,
		cast(i32)ground_width,
		cast(i32)ground_height,
		xray.GREEN,
	)
	//bottom_left_corner := b2.Body_GetPosition(world.ground_id)
	//top_left_corner := b2.Vec2{bottom_left_corner.x, bottom_left_corner.y + 2*(center.y - bottom_left_corner.x)}
	//log.debugf("rendering ground at %v -> %v -> %v", bottom_left_corner, center, top_left_corner)
}

render :: proc(world: World) {
	log.info("rendering...")

	xray.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "sandbox odin experiments")
	defer xray.CloseWindow()

	xray.SetTargetFPS(FPS)

	for !xray.WindowShouldClose() {
		free_all(context.temp_allocator)
		tick(world)
		xray.BeginDrawing()
		defer xray.EndDrawing()

		xray.ClearBackground(xray.LIGHTGRAY)

		renderGround(world)
		for box in world.boxes {
			renderBox(box)
		}
	}
}
