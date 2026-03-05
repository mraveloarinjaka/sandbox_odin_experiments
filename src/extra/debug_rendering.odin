package core

import b2 "vendor:box2d"
import xray "vendor:raylib"

import "core:fmt"
import "core:log"
import "core:testing"

makeDebugDrawer :: proc(renderData: ^DebugRenderData) -> b2.DebugDraw {
	return b2.DebugDraw {
		userContext = rawptr(renderData),
		drawShapes = true,
		drawMass = true,
		DrawPolygonFcn = proc "c" (
			vertices: [^]b2.Vec2,
			vertexCount: i32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			fmt.println("drawing polygon")
		},
		DrawSolidPolygonFcn = proc "c" (
			transform: b2.Transform,
			vertices: [^]b2.Vec2,
			vertexCount: i32,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			fmt.printfln("drawing solid polygon %v", vertices)
			for idx in 0 ..< vertexCount {
				start := toSceneCoordinates(
					b2.TransformPoint(transform, vertices[idx]),
					data.camera,
				)
				end := toSceneCoordinates(
					b2.TransformPoint(transform, vertices[(idx + 1) % vertexCount]),
					data.camera,
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
		DrawCircleFcn = proc "c" (center: b2.Vec2, radius: f32, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			fmt.println("drawing circle")
			converted_center := toSceneCoordinates(center, data.camera)
			converted_radius := radius * PIXELS_PER_METER
			xray.DrawCircle(
				cast(i32)converted_center.x,
				cast(i32)converted_center.y,
				converted_radius,
				hex_2_rgb(color),
			)
		},
		DrawSolidCircleFcn = proc "c" (
			transform: b2.Transform,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debug("drawing solid circle")
			center := transform.p
			converted_center := toSceneCoordinates(center, data.camera)
			converted_radius := radius * PIXELS_PER_METER
			xray.DrawCircle(
				cast(i32)converted_center.x,
				cast(i32)converted_center.y,
				converted_radius,
				hex_2_rgb(color),
			)
		},
		DrawSolidCapsuleFcn = proc "c" (
			p1, p2: b2.Vec2,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing capsule with radius %v", radius)
			converted_center1 := toSceneCoordinates(p1, data.camera)
			converted_center2 := toSceneCoordinates(p2, data.camera)
			converted_radius := radius * PIXELS_PER_METER
			xray.DrawCircle(
				cast(i32)converted_center1.x,
				cast(i32)converted_center1.y,
				converted_radius,
				hex_2_rgb(color),
			)
			xray.DrawCircle(
				cast(i32)converted_center2.x,
				cast(i32)converted_center2.y,
				converted_radius,
				hex_2_rgb(color),
			)
		},
		DrawSegmentFcn = proc "c" (p1, p2: b2.Vec2, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing segement from %v to %v", p1, p2)
		},
		DrawTransformFcn = proc "c" (transform: b2.Transform, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing transform %v", transform)
		},
		DrawPointFcn = proc "c" (p: b2.Vec2, size: f32, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing point %v", p)
		},
		DrawStringFcn = proc "c" (p: b2.Vec2, s: cstring, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing string %v at %v", s, p)
		},
	}}

hex_2_rgb :: proc(hex: b2.HexColor) -> (color: xray.Color) {
	n := transmute(u32)(hex)
	color.r = cast(u8)((n >> 16) & 0xFF)
	color.g = cast(u8)((n >> 8) & 0xFF)
	color.b = cast(u8)(n & 0xFF)
	color.a = 255
	return
}

@(test)
testing_hex_2_rgb :: proc(t: ^testing.T) {
	hex := b2.HexColor.Green
	color := xray.Color{0, 128, 0, 255}
	testing.expect_value(t, hex_2_rgb(hex), color)
}
