package core

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:testing"

makeDebugDrawer :: proc() -> b2.DebugDraw {
	return b2.DebugDraw {
		drawShapes = true,
		drawMass = true,
		DrawPolygon = proc "c" (
			vertices: [^]b2.Vec2,
			vertexCount: i32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			context = runtime.default_context()
			fmt.println("drawing polygon")
		},
		DrawSolidPolygon = proc "c" (
			transform: b2.Transform,
			vertices: [^]b2.Vec2,
			vertexCount: i32,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			context = runtime.default_context()
			fmt.printfln("drawing solid polygon %v", vertices)
			for idx in 0 ..< vertexCount {
				start := toSceneCoordinates(b2.TransformPoint(transform, vertices[idx]))
				end := toSceneCoordinates(
					b2.TransformPoint(transform, vertices[(idx + 1) % vertexCount]),
				)
				xray.DrawLine(
					cast(i32)start.x,
					cast(i32)start.y,
					cast(i32)end.x,
					cast(i32)end.y,
					hex_2_rgb(color),
				)
			}
		},
		DrawCircle = proc "c" (center: b2.Vec2, radius: f32, color: b2.HexColor, ctx: rawptr) {
			context = runtime.default_context()
			fmt.println("drawing circle")
			converted_center := toSceneCoordinates(center)
			converted_radius := radius * PIXELS_PER_METER
			xray.DrawCircle(
				cast(i32)converted_center.x,
				cast(i32)converted_center.y,
				converted_radius,
				hex_2_rgb(color),
			)
		},
		DrawSolidCircle = proc "c" (
			transform: b2.Transform,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			context = runtime.default_context()
			log.debug("drawing solid circle")
			center := transform.p
			converted_center := toSceneCoordinates(center)
			converted_radius := radius * PIXELS_PER_METER
			xray.DrawCircle(
				cast(i32)converted_center.x,
				cast(i32)converted_center.y,
				converted_radius,
				hex_2_rgb(color),
			)
		},
		DrawCapsule = proc "c" (p1, p2: b2.Vec2, radius: f32, color: b2.HexColor, ctx: rawptr) {},
		DrawSolidCapsule = proc "c" (
			p1, p2: b2.Vec2,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {},
		DrawSegment = proc "c" (p1, p2: b2.Vec2, color: b2.HexColor, ctx: rawptr) {},
		DrawTransform = proc "c" (transform: b2.Transform, ctx: rawptr) {},
		DrawPoint = proc "c" (p: b2.Vec2, size: f32, color: b2.HexColor, ctx: rawptr) {},
		DrawString = proc "c" (p: b2.Vec2, s: cstring, ctx: rawptr) {
			context = runtime.default_context()
			log.debugf("drawing string %v", s)
		},
	}}

hex_2_rgb :: proc(hex: b2.HexColor) -> (color: xray.Color) {
	//color = {
	//   (cast(u8)(transmute(i32)(hex) >> 16) & 0xFF),
	//   (cast(u8)(transmute(i32)(hex) >> 8) & 0xFF),
	//   (cast(u8)(transmute(i32)(hex) & 0xFF)),
	//   255,
	//}
	bits := transmute([4]u8)(hex)
	color.r = bits[0]
	color.g = bits[1]
	color.b = bits[2]
	color.a = 255
	return
}

@(test)
testing_hex_2_rgb :: proc(t: ^testing.T) {
	hex := b2.HexColor.Green
	color := xray.Color{0, 255, 0, 255}
	testing.expect(t, color == hex_2_rgb(hex))
}
