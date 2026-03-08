package sim

import b2 "vendor:box2d"
import xray "vendor:raylib"
import "vendor:raylib/rlgl"

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math"

SCREEN_SPACE_ORIGIN_X :: WINDOW_WIDTH / 2
SCREEN_SPACE_ORIGIN_Y :: (WINDOW_HEIGHT - 20)

SCREEN_CORNERS: [4]xray.Vector2 = {
	{0, 0}, //top left
	{WINDOW_WIDTH, 0}, //top right
	{WINDOW_WIDTH, WINDOW_HEIGHT}, //bottom right
	{0, WINDOW_HEIGHT}, //bottom left
}

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

getWorldAABB :: proc(camera: xray.Camera2D) -> (aabbMin, aabbMax: b2.Vec2) {
	aabbMin = b2.Vec2{math.F32_MAX, math.F32_MAX}
	aabbMax = b2.Vec2{-math.F32_MAX, -math.F32_MAX}
	for i in 0 ..< 4 {
		w := xray.GetScreenToWorld2D(SCREEN_CORNERS[i], camera)
		aabbMin.x = math.min(aabbMin.x, w.x)
		aabbMin.y = math.min(aabbMin.y, -w.y)
		aabbMax.x = math.max(aabbMax.x, w.x)
		aabbMax.y = math.max(aabbMax.y, -w.y)
	}
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
	useDebugRendering := true

	xray.SetTargetFPS(FPS)

	for !xray.WindowShouldClose() {
		free_all(context.temp_allocator)
		if xray.IsKeyDown(xray.KeyboardKey.SPACE) {
			generateMoreBodies(world)
		}
		if xray.IsKeyPressed(xray.KeyboardKey.D) {
			useDebugRendering = !useDebugRendering
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
		if xray.IsKeyDown(xray.KeyboardKey.R) {
			camera.target = {0, 0}
		}
		tick(world^)
		xray.BeginDrawing()
		defer xray.EndDrawing()

		xray.ClearBackground(xray.BLANK)

		{
			xray.BeginMode2D(camera)
			defer {xray.EndMode2D()}
			{
				rlgl.PushMatrix()
				defer {rlgl.PopMatrix()}
				rlgl.Scalef(1, -1, 1)

				if useDebugRendering {
					debugRenderData.ctx = context
					debug := makeDebugDrawer(&debugRenderData)

					aabbMin, aabbMax := getWorldAABB(camera)
					log.debugf("min %v - max %v", aabbMin, aabbMax)
					debug.drawingBounds = {
						lowerBound = aabbMin,
						upperBound = aabbMax,
					}
					debug.useDrawingBounds = true

					b2.World_Draw(world.world_id, &debug)
				} else {
					renderWorld(world.world_id)
				}
			}
			xray.DrawCircle(0, 0, .5, xray.WHITE)
			xray.DrawTextEx(xray.GetFontDefault(), "Origin", {0, 0.5}, 1, 1, xray.RAYWHITE)
		}
		drawControls(camera, useDebugRendering)
	}
}

drawControls :: proc(camera: xray.Camera2D, useDebugRendering: bool) {
	xray.DrawText("Controls:", 20, 20, 20, xray.PURPLE)
	xray.DrawText("- SPACE to generate bodies", 40, 40, 20, xray.LIGHTGRAY)
	xray.DrawText("- R to reset camera", 40, 60, 20, xray.LIGHTGRAY)
	xray.DrawText("- D to toggle debug/custom rendering", 40, 80, 20, xray.LIGHTGRAY)
	
	modeText := "Debug" if useDebugRendering else "Custom"
	modeColor := xray.GREEN if useDebugRendering else xray.BLUE
	xray.DrawText(fmt.ctprintf("Rendering: %s", modeText), 20, 100, 20, modeColor)
	
	xray.DrawFPS(SCREEN_SPACE_ORIGIN_X, SCREEN_SPACE_ORIGIN_Y)
}
