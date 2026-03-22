package entry_point

import "core:log"

import "sim"

main :: proc() {
	context.logger = log.create_console_logger(log.Level.Debug)
	log.debug("hello odin world!")
	world := sim.createWorld()
	defer {sim.releaseWorld(world)}
	sim.render(&world)
}
