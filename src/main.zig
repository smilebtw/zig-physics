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

pub fn main() void {
    const window_width: i32 = 1000;
    const window_height: i32 = 1000;

    const Blocks = enum { SAND, DIRT, WATER, AIR };

    var BlocksColor = std.EnumArray(Blocks, raylib.Color).initUndefined();
    BlocksColor.set(Blocks.AIR, raylib.BLACK);
    BlocksColor.set(Blocks.SAND, raylib.YELLOW);
    BlocksColor.set(Blocks.DIRT, raylib.BROWN);
    BlocksColor.set(Blocks.WATER, raylib.BLUE);

    var Grid: [800][800]Blocks = undefined;

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

    var gameScreenWidth: i32 = 800;
    var gameScreenHeight: i32 = 800;

    const target: raylib.RenderTexture2D = raylib.LoadRenderTexture(gameScreenWidth, gameScreenHeight);
    defer raylib.UnloadRenderTexture(target);
    raylib.SetTextureFilter(target.texture, raylib.RL_TEXTURE_FILTER_LINEAR);

    var isDrawing: bool = false;
    while (!raylib.WindowShouldClose()) {
        var screenWidth: f32 = @floatFromInt(raylib.GetScreenWidth());
        var screenHeight: f32 = @floatFromInt(raylib.GetScreenHeight());
        var gameScreenWidth_f: f32 = @floatFromInt(gameScreenWidth);
        var gameScreenHeight_f: f32 = @floatFromInt(gameScreenHeight);
        var scale: f32 = min(screenWidth / gameScreenWidth_f, screenHeight / gameScreenHeight_f);

        var mouse: raylib.Vector2 = raylib.GetMousePosition();
        var virtualMouse = raylib.Vector2{ .x = 0 };
        virtualMouse.x = (mouse.x - screenWidth - (gameScreenWidth_f * scale) * 0.5) / scale;
        virtualMouse.y = (mouse.y - screenHeight - (gameScreenHeight_f * scale) * 0.5) / scale;
        virtualMouse = raylib.Vector2Clamp(virtualMouse, raylib.Vector2{ .x = 0, .y = 0 }, raylib.Vector2{ .x = gameScreenWidth_f, .y = gameScreenHeight_f });

        if (raylib.IsMouseButtonDown(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = true;
        } else if (raylib.IsMouseButtonUp(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = false;
        }

        raylib.BeginTextureMode(target);
        defer raylib.EndDrawing();
        raylib.ClearBackground(raylib.BLACK);
        if (isDrawing) {
            var posX: u32 = @intFromFloat(virtualMouse.x);
            var posY: u32 = @intFromFloat(virtualMouse.y);

            Grid[posY][posX] = Blocks.DIRT;
        }

        for (0..@intCast(gameScreenHeight)) |y| {
            for (0..@intCast(gameScreenWidth)) |x| {
                if (Grid[y][x] != Blocks.AIR) {
                    raylib.DrawPixel(@intCast(x), @intCast(y), BlocksColor.get(Grid[y][x]));
                }
            }
        }
        raylib.EndTextureMode();

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}
