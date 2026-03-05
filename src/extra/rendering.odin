package core

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "base:runtime"
import "core:fmt"
import "core:log"

SCREEN_SPACE_ORIGIN_X :: WINDOW_WIDTH / 2
SCREEN_SPACE_ORIGIN_Y :: (WINDOW_HEIGHT - 20)

Camera :: struct {
	offset_x: int,
	offset_y: int,
	target_x: f32,
	target_y: f32,
}

DebugRenderData :: struct {
	camera: Camera,
	ctx:    runtime.Context,
}

toSceneCoordinates :: proc "contextless" (coord: b2.Vec2) -> (result: xray.Vector2) {
	result.x = coord.x
	result.y = -coord.y
	return
}

render :: proc(world: ^World) {
	log.info("rendering...")

	xray.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "sandbox odin experiments")
	defer xray.CloseWindow()

	camera := xray.Camera2D{}
	camera.offset = {WINDOW_WIDTH / 2, 3 * WINDOW_HEIGHT / 4}
	camera.target = {0, 0}
	camera.zoom = PIXELS_PER_METER

	debugRenderData := DebugRenderData{}

	xray.SetTargetFPS(FPS)

	for !xray.WindowShouldClose() {
		free_all(context.temp_allocator)
		if xray.IsKeyDown(xray.KeyboardKey.SPACE) {
			generateMoreBodies(world)
		}
		if xray.IsKeyDown(xray.KeyboardKey.K) {
			camera.target.y -= .5
		}
		if xray.IsKeyDown(xray.KeyboardKey.J) {
			camera.target.y += .5
		}
		if xray.IsKeyDown(xray.KeyboardKey.L) {
			camera.target.x += .5
		}
		if xray.IsKeyDown(xray.KeyboardKey.H) {
			camera.target.x -= .5
		}
		tick(world^)
		xray.BeginDrawing()
		defer xray.EndDrawing()

		xray.ClearBackground(xray.BLANK)

		{
			xray.BeginMode2D(camera)
			defer {xray.EndMode2D()}
			debugRenderData.ctx = context
			debug := makeDebugDrawer(&debugRenderData)
			b2.World_Draw(world.world_id, &debug)
			xray.DrawCircle(0, 0, .5, xray.WHITE)
			xray.DrawTextEx(
				xray.GetFontDefault(),
				"Origin",
				{0, 0.5},
				1,
				1,
				xray.RAYWHITE,
			)
		}
		drawControls(camera)
	}
}

drawControls :: proc(camera: xray.Camera2D) {
	xray.DrawText("Controls:", 20, 20, 20, xray.PURPLE)
	xray.DrawText("- SPACE to generate bodies", 40, 40, 20, xray.LIGHTGRAY)
	xray.DrawFPS(SCREEN_SPACE_ORIGIN_X, SCREEN_SPACE_ORIGIN_Y)
}
