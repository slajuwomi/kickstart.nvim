-- image.nvim
-- https://github.com/3rd/image.nvim
--
-- Renders images in Ghostty/Kitty via the Kitty graphics protocol.
-- Open a PNG/JPEG/WebP/GIF/AVIF, or a Markdown file with image links.

return {
  '3rd/image.nvim',
  -- Load at startup so opening a PNG/JPEG hijacks the buffer instead of showing binary.
  lazy = false,
  build = false, -- don't build the magick Lua rock; use ImageMagick CLI instead
  opts = {
    backend = 'kitty',
    processor = 'magick_cli',
    integrations = {
      markdown = {
        enabled = true,
      },
    },
    max_height_window_percentage = 50,
    hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
  },
}
