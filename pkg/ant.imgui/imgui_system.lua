local ecs = ...
local world = ecs.world

local platform = require "bee.platform"
local ImGui = require "imgui"
local ImGuiAnt = import_package "ant.imgui"
local ImGuiBackend = require "imgui.backend"
local rhwi = import_package "ant.hwi"
local assetmgr = import_package "ant.asset"
local window = import_package "ant.window"
local PM = require "programan.client"
local viewIdPool = require "viewid_pool"

local m = ecs.system 'imgui_system'

function m:init_system()
	ImGui.CreateContext()
	ImGuiBackend.Init()
	local ConfigFlags = {
		"NavEnableKeyboard",
		"DockingEnable",
		"NavNoCaptureKeyboard",
		"NoMouseCursorChange",
	}
	if platform.os == "windows" then
		ConfigFlags[#ConfigFlags+1] = "DpiEnableScaleFonts"
	end
	ImGui.GetIO().ConfigFlags = ImGui.ConfigFlags(ConfigFlags)
	ImGuiBackend.PlatformInit(rhwi.native_window())

	local imgui_font = assetmgr.load_material "/pkg/ant.imgui/materials/font.material"
	local imgui_image = assetmgr.load_material "/pkg/ant.imgui/materials/image.material"
	assetmgr.material_mark(imgui_font.fx.prog)
	assetmgr.material_mark(imgui_image.fx.prog)
	ImGuiBackend.RenderInit {
		fontProg = PM.program_get(imgui_font.fx.prog),
		imageProg = PM.program_get(imgui_image.fx.prog),
		fontUniform = imgui_font.fx.uniforms.s_tex.handle,
		imageUniform = imgui_image.fx.uniforms.s_tex.handle,
		viewIdPool = viewIdPool,
	}
	if platform.os == "windows" then
		ImGuiAnt.FontAtlasAddFont {
			SystemFont = "Segoe UI Emoji",
			SizePixels = 18,
			GlyphRanges = { 0x23E0, 0x329F, 0x1F000, 0x1FA9F }
		}
	end
	ImGuiAnt.FontAtlasAddFont {
		FontPath = "/pkg/ant.resources.binary/font/Alibaba-PuHuiTi-Regular.ttf",
		SizePixels = 18,
		GlyphRanges = { 0x0020, 0xFFFF }
	}
	world:enable_imgui()
end

function m:init_world()
	ImGuiAnt.FontAtlasBuild()
end

function m:exit()
	ImGuiBackend.RenderDestroy()
	ImGuiBackend.PlatformDestroy()
	ImGui.DestroyContext()
end

local last_cursor = 0

function m:start_frame()
	local cursor = ImGui.GetMouseCursor()
	if last_cursor ~= cursor then
		last_cursor = cursor
		window.set_cursor(cursor)
	end
	ImGuiBackend.PlatformNewFrame()
	ImGui.NewFrame()
end

function m:end_frame()
	ImGui.Render()
	ImGuiBackend.RenderDrawData()
	ImGui.UpdatePlatformWindows()
	ImGui.RenderPlatformWindowsDefault()
end
