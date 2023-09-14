const std = @import("std");
const raylib = @import("raylib");

pub fn main() void {
    const WIDTH: i32 = 200;
    const HEIGHT: i32 = 200;

    const Blocks = enum { SAND, DIRT, WATER, AIR };

    var BlocksColor = std.EnumArray(Blocks, raylib.Color).initUndefined();
    BlocksColor.set(Blocks.AIR, raylib.BLACK);
    BlocksColor.set(Blocks.SAND, raylib.YELLOW);
    BlocksColor.set(Blocks.DIRT, raylib.BROWN);
    BlocksColor.set(Blocks.WATER, raylib.BLUE);

    var Grid: [200][200]Blocks = undefined;

    for (Grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            Grid[y][x] = Blocks.AIR;
        }
    }

    raylib.InitWindow(WIDTH, HEIGHT, "sandbox!");
    defer raylib.CloseWindow();
    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    var isDrawing: bool = false;
    while (!raylib.WindowShouldClose()) {
        if (raylib.IsMouseButtonDown(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = true;
        } else if (raylib.IsMouseButtonUp(raylib.MouseButton.MOUSE_BUTTON_LEFT)) {
            isDrawing = false;
        }

        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        raylib.ClearBackground(raylib.BLACK);

        if (isDrawing) {
            var mousePosition: raylib.Vector2 = raylib.GetMousePosition();
            var posX: u32 = @intFromFloat(mousePosition.x);
            var posY: u32 = @intFromFloat(mousePosition.y);

            Grid[posY][posX] = Blocks.DIRT;
        }

        var h: u32 = 0;
        var w: u32 = 0;
        for (h..HEIGHT) |y| {
            for (w..WIDTH) |x| {
                if (Grid[y][x] != Blocks.AIR) {
                    raylib.DrawPixel(@intCast(x), @intCast(y), BlocksColor.get(Grid[y][x]));
                }
            }
        }

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}
