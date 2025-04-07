package main

import "core:fmt"
import "core:log"

import "extra"

main :: proc() {
	context.logger = log.create_console_logger(log.Level.Debug)
	fmt.println("hello odin world!")
	world := extra.createWorld()
	defer {extra.releaseWorld(world)}
	extra.render(world)
}
