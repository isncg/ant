package.path = "/engine/?.lua"
require "bootstrap"

dofile "/engine/ltask.lua" {
    bootstrap = { "s|listen", arg },
    exclusive = { "timer", "s|network" },
    logger = { "s|log.server" },
}
