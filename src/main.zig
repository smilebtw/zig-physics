const std = @import("std");
const raylib = @import("raylib");
const raymath = @cImport({
    @cInclude("raylib.h");
});

pub fn max(a: f32, b: f32) f32 {
    if (a > b) {
        return a;
    }
    return b;
}

pub fn min(a: f32, b: f32) f32 {
    if (a < b) {
        return a;
    }
    return b;
}

pub fn main() !void {
    const window_width: i32 = 1000;
    const window_height: i32 = 1000;
    const zoom_factor: f32 = 5.0;

    const Blocks = enum { SAND, DIRT, WATER, AIR };

    var BlocksColor = std.EnumArray(Blocks, raylib.Color).initUndefined();
    BlocksColor.set(Blocks.AIR, raylib.BLACK);
    BlocksColor.set(Blocks.SAND, raylib.YELLOW);
    BlocksColor.set(Blocks.DIRT, raylib.BROWN);
    BlocksColor.set(Blocks.WATER, raylib.BLUE);

    var Grid: [1000][1000]Blocks = undefined;

    for (Grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            Grid[y][x] = Blocks.AIR;
        }
    }

    raylib.InitWindow(window_width, window_height, "sandbox!");
    defer raylib.CloseWindow();
    raylib.SetWindowMinSize(400, 400);
    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true, .FLAG_VSYNC_HINT = true });
    raylib.SetTargetFPS(60);

    var game_screen_width: i32 = 800;
    var game_screen_height: i32 = 800;

    const target: raylib.RenderTexture2D = raylib.LoadRenderTexture(game_screen_width, game_screen_height);
    defer raylib.UnloadRenderTexture(target);
    raylib.SetTextureFilter(target.texture, raylib.RL_TEXTURE_FILTER_LINEAR);

    var isDrawing: bool = false;
    while (!raylib.WindowShouldClose()) {
        var screen_width: f32 = @floatFromInt(raylib.GetScreenWidth());
        var screen_height: f32 = @floatFromInt(raylib.GetScreenHeight());

        var game_screen_width_f: f32 = @floatFromInt(game_screen_width);
        var game_screen_height_f: f32 = @floatFromInt(game_screen_height);

        var scale: f32 = min(screen_width / game_screen_width_f, screen_height / game_screen_height_f) * zoom_factor;

        var mouse: raylib.Vector2 = raylib.GetMousePosition();
        var virtualMouse = raylib.Vector2{ .x = 0, .y = 0 };
        virtualMouse.x = (mouse.x - (screen_width - (game_screen_width_f * scale)) * 0.5) / scale;
        virtualMouse.y = (mouse.y - (screen_height - (game_screen_height_f * scale)) * 0.5) / scale;
        virtualMouse = raylib.Vector2Clamp(virtualMouse, raylib.Vector2{ .x = 0, .y = 0 }, raylib.Vector2{ .x = game_screen_width_f, .y = game_screen_height_f });

        if (raylib.IsMouseButtonDown(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = true;
        } else if (raylib.IsMouseButtonUp(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = false;
        }

        raylib.BeginTextureMode(target);
        raylib.ClearBackground(raylib.BLACK);
        if (isDrawing) {
            var posX: u32 = @intFromFloat(virtualMouse.x);
            var posY: u32 = @intFromFloat(virtualMouse.y);
            Grid[posY][posX] = Blocks.DIRT;
        }

        for (0..@intCast(game_screen_height)) |y| {
            for (0..@intCast(game_screen_width)) |x| {
                if (Grid[y][x] != Blocks.AIR) {
                    raylib.DrawPixel(@intCast(x), @intCast(y), BlocksColor.get(Grid[y][x]));
                }
            }
        }

        raylib.EndTextureMode();

        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.BLACK);

        var destRec: raylib.Rectangle = raylib.Rectangle{ .x = (screen_width - game_screen_width_f * scale) * 0.5, .y = (screen_height - game_screen_height_f * scale) * 0.5, .width = game_screen_width_f * scale, .height = game_screen_height_f * scale };

        raylib.DrawTexturePro(target.texture, raylib.Rectangle{ .x = 0, .y = 0, .width = game_screen_width_f, .height = game_screen_height_f }, destRec, raylib.Vector2{ .x = 0, .y = 0 }, 0.0, raylib.WHITE);
        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}
