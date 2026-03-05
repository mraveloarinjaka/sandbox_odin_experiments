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

toSceneCoordinates :: proc "contextless" (
	coord: b2.Vec2,
	offset: Camera,
) -> (
	result: xray.Vector2,
) {
	offset_x := offset.offset_x
	target_x := offset.target_x
	result.x = ((coord.x - target_x) * PIXELS_PER_METER) + cast(f32)offset_x

	offset_y := offset.offset_y
	target_y := offset.target_y
	result.y = (-(coord.y - target_y) * PIXELS_PER_METER) + cast(f32)offset_y
	//result.x = coord.x
	//result.y = -coord.y
	return
}

render :: proc(world: ^World) {
	log.info("rendering...")

	xray.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "sandbox odin experiments")
	defer xray.CloseWindow()

	camera := xray.Camera2D{}
	camera.offset = {WINDOW_WIDTH / 2, 3 * WINDOW_HEIGHT / 4}
	camera.zoom = PIXELS_PER_METER

	debugRenderData := DebugRenderData{}
	customCamera := &debugRenderData.camera
	customCamera.offset_x = SCREEN_SPACE_ORIGIN_X
	customCamera.offset_y = SCREEN_SPACE_ORIGIN_Y

	xray.SetTargetFPS(FPS)

	for !xray.WindowShouldClose() {
		free_all(context.temp_allocator)
		if xray.IsKeyDown(xray.KeyboardKey.SPACE) {
			generateMoreBodies(world)
		}
		if xray.IsKeyDown(xray.KeyboardKey.K) {
			customCamera.target_y += .5
			camera.target.y -= .5
		}
		if xray.IsKeyDown(xray.KeyboardKey.J) {
			customCamera.target_y -= .5
			camera.target.y += .5
		}
		tick(world^)
		xray.BeginDrawing()
		defer xray.EndDrawing()

		xray.ClearBackground(xray.BLANK)

		{
			//xray.BeginMode2D(camera)
			//defer {xray.EndMode2D()}
			debugRenderData.ctx = context
			debug := makeDebugDrawer(&debugRenderData)
			b2.World_Draw(world.world_id, &debug)
			xray.DrawCircle(0, 0, .5, xray.WHITE)
		}
		drawControls(camera)
	}
}

drawControls :: proc(camera: xray.Camera2D) {
	xray.DrawText("Controls:", 20, 20, 20, xray.PURPLE)
	xray.DrawText("- SPACE to generate bodies", 40, 40, 20, xray.LIGHTGRAY)
	origin := toSceneCoordinates(
		{0, 0},
		{
			offset_x = SCREEN_SPACE_ORIGIN_X,
			offset_y = SCREEN_SPACE_ORIGIN_Y,
			target_x = 0,
			target_y = 0,
		},
	)
	//origin := xray.GetWorldToScreen2D(xray.Vector2{0, 0}, camera)
	xray.DrawText("Origin", cast(i32)origin.x, cast(i32)origin.y, 20, xray.RAYWHITE)
	xray.DrawCircle(SCREEN_SPACE_ORIGIN_X, SCREEN_SPACE_ORIGIN_Y, 5, xray.RAYWHITE)
}
