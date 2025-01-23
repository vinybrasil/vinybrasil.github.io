const std = @import("std");
const zine = @import("zine");

pub fn build(b: *std.Build) !void {
    zine.website(b, .{
        .title = "Viny Brasil's Blog",
        .host_url = "https://vinybrasil.github.io",
        .layouts_dir_path = "layouts",
        .content_dir_path = "content",
        .assets_dir_path = "assets",
        .static_assets = &.{
            "favicon.ico",
            "CNAME",
            ".well-known/atproto-did",
        },
        .debug = true,
    });
}
