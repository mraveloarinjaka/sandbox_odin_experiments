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
				start := toSceneCoordinates(b2.TransformPoint(transform, vertices[idx]))
				end := toSceneCoordinates(
					b2.TransformPoint(transform, vertices[(idx + 1) % vertexCount]),
				)
				xray.DrawLineV(start, end, hex_2_rgb(color))
			}
		},
		DrawCircleFcn = proc "c" (center: b2.Vec2, radius: f32, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			fmt.println("drawing circle")
			xray.DrawCircleV(toSceneCoordinates(center), radius, hex_2_rgb(color))
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
			center := toSceneCoordinates(transform.p)
			xray.DrawCircleV(center, radius, hex_2_rgb(color))
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
			xray.DrawCircleV(toSceneCoordinates(p1), radius, hex_2_rgb(color))
			xray.DrawCircleV(toSceneCoordinates(p2), radius, hex_2_rgb(color))
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

hex_2_rgb :: proc(hex: b2.HexColor) -> xray.Color {
	return xray.GetColor(cast(u32)(hex))
}

@(test)
testing_hex_2_rgb :: proc(t: ^testing.T) {
	hex := b2.HexColor.Green
	color := xray.Color{0, 128, 0, 255}
	testing.expect_value(t, hex_2_rgb(hex), color)
}
