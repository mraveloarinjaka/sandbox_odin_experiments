package core

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "base:runtime"
import "core:fmt"
import "core:log"

toSceneCoordinates :: proc "contextless" (coord: b2.Vec2) -> (result: xray.Vector2) {
	result.x = coord.x * PIXELS_PER_METER
	result.y = (WINDOW_HEIGHT - 20) - coord.y * PIXELS_PER_METER
	return
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

		xray.ClearBackground(xray.WHITE)

		debug := makeDebugDrawer()

		b2.World_Draw(world.world_id, &debug)
	}
}

