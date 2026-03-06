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
			log.debugf("drawing polygon %v", vertices)
			for idx in 0 ..< vertexCount {
				start := vertices[idx]
				end := vertices[(idx + 1) % vertexCount]
				xray.DrawLineV(start, end, hex_2_rgb(color))
			}
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
			log.debugf("drawing solid polygon %v", vertices)
			for idx in 0 ..< vertexCount {
				start := b2.TransformPoint(transform, vertices[idx])
				end := b2.TransformPoint(transform, vertices[(idx + 1) % vertexCount])
				xray.DrawLineV(start, end, hex_2_rgb(color))
			}
		},
		DrawCircleFcn = proc "c" (center: b2.Vec2, radius: f32, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debug("drawing circle")
			xray.DrawCircleV(center, radius, hex_2_rgb(color))
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
			xray.DrawCircleV(transform.p, radius, hex_2_rgb(color))
		},
		DrawSolidCapsuleFcn = proc "c" (
			p1, p2: b2.Vec2,
			radius: f32,
			color: b2.HexColor,
			ctx: rawptr,
		) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing capsule from %v to %v with radius %v", p1, p2, radius)
			xray.DrawCircleLinesV(p1, radius, hex_2_rgb(color))
			xray.DrawCircleLinesV(p2, radius, hex_2_rgb(color))
		},
		DrawSegmentFcn = proc "c" (p1, p2: b2.Vec2, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing segment from %v to %v", p1, p2)
			xray.DrawLineV(p1, p2, hex_2_rgb(color))
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
			xray.DrawPixelV(p, hex_2_rgb(color))
		},
		DrawStringFcn = proc "c" (p: b2.Vec2, s: cstring, color: b2.HexColor, ctx: rawptr) {
			data := cast(^DebugRenderData)(ctx)
			context = data.ctx
			log.debugf("drawing string %s at %v", s, p)
			//xray.DrawTextEx(xray.GetFontDefault(), s, p, 1, 1, hex_2_rgb(color))
		},
	}}

hex_2_rgb :: proc(hex: b2.HexColor) -> xray.Color {
	// does not work on ARM - little-endian
	//color := transmute([4]u8)(hex)
	//return {color[1], color[2], color[3], 255}
	// << 8 always means multiply by 256
	return xray.GetColor(transmute(u32)(hex) << 8 | 0xFF)
}

@(test)
testing_hex_2_rgb :: proc(t: ^testing.T) {
	testing.expect_value(t, hex_2_rgb(b2.HexColor.Green), xray.Color{0, 128, 0, 255})
	testing.expect_value(t, hex_2_rgb(b2.HexColor.Red), xray.Color{255, 0, 0, 255})
}
