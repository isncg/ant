local ecs   = ...
local world = ecs.world
local w     = world.w

local math3d= require "math3d"

local common= ecs.require "common"

local ig    = ecs.require "ant.group|group"
local iom   = ecs.require "ant.objcontroller|obj_motion"
local irender = ecs.require "ant.render|render"
local group_test_sys = common.test_system "group"

local util  = ecs.require "util"
local PC    = util.proxy_creator()

local group_states = {
    group_test1 = {
        gid = ig.register "group_test1",
        enable = true,
    },
    group_test2 = {
        gid = ig.register "group_test2",
        enable = true,
    }
}

function group_test_sys:init()
    local g1, g2 = group_states.group_test1.gid, group_states.group_test2.gid

    PC:create_instance {
        prefab = "/pkg/ant.resources.binary/meshes/base/cube.glb|mesh.prefab",
        group = g1,
        on_ready = function(e)
            local eid = e.tag['*'][1]
            local ee<close> = world:entity(eid, "scene:in")
            iom.set_position(ee, math3d.vector(5, 0, 0, 1))
        end
    }

    PC:create_instance {
        prefab = "/pkg/ant.resources.binary/meshes/base/cone.glb|mesh.prefab",
        group = g1,
        on_ready = function(e)
            local eid = e.tag['*'][1]
            local ee<close> = world:entity(eid, "scene:in")
        end
    }

    PC:create_instance {
        prefab = "/pkg/ant.resources.binary/meshes/base/cylinder.glb|mesh.prefab",
        group = g2,
        on_ready = function(e)
            local eid = e.tag['*'][1]
            local ee<close> = world:entity(eid, "scene:in")
            iom.set_position(ee, math3d.vector(10, 0, 0, 1))
        end
    }

    PC:create_instance {
        prefab = "/pkg/ant.resources.binary/meshes/base/ring.glb|mesh.prefab",
        group = g2,
        on_ready = function(e)
            local eid = e.tag['*'][1]
            local ee<close> = world:entity(eid, "scene:in")
            iom.set_position(ee, math3d.vector(10, 0, 10, 1))
        end
    }

    for k, v in pairs(group_states) do
        ig.enable_from_name(k, "view_visible", v)
    end
end

function group_test_sys:entity_init()
    -- for e in w:select "INIT render_object eid:in view_visible?in" do
    --     print("render_object INIT:", e.eid, "view_visible:", e.view_visible)
    -- end
end

local kb_mb = world:sub{"keyboard"}

local function switch_group_visible(who)
    local g = group_states[who]
    g.enable = not g.enable

    local go = ig.obj "view_visible"
    go:enable(g.gid, g.enable)
    irender.group_flush(go)
end

function group_test_sys:data_changed()
    for _, key, press in kb_mb:unpack() do
        if key == "G" and press == 0 then
            switch_group_visible "group_test1"
        elseif key == "H" and press == 0 then
            switch_group_visible "group_test2"
        elseif key == "B" and press == 0 then
            PC:create_instance {
                prefab = "/pkg/ant.resources.binary/meshes/base/ring.glb|mesh.prefab",
                group = ig.groupid "group_test2",
                on_ready = function(e)
                    local eid = e.tag['*'][1]
                    local ee<close> = world:entity(eid, "scene:in")
                    iom.set_position(ee, math3d.vector(0, 0, 10, 1))
                end
            }
        end
    end
end

-- function group_test_sys:render_submit()
--     do
-- 		print("view_visible:", w:count "view_visible")
-- 		print("render_object:", w:count "render_object")
-- 		print("render_object_visible:", w:count "render_object_visible")
-- 		print("render_object view_visible:", w:count "render_object view_visible")
-- 	end
-- end


function group_test_sys:exit()
    PC:clear()
end