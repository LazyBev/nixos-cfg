config.load_autoconfig()

# Omnisearch default engine + keyword
c.url.searchengines["DEFAULT"] = "http://localhost:8087/search?q={}"
c.url.searchengines["omni"] = "http://localhost:8087/search?q={}"

# Adblock
c.content.blocking.method = "auto"
c.content.blocking.hosts.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
]

# c.content.user_stylesheets = ["~/.config/qutebrowser/styles/youtube.css"]

c.colors.statusbar.normal.bg = "#1e1e2e"
c.colors.statusbar.command.bg = "#1e1e2e"
c.colors.statusbar.command.fg = "#cdd6f4"
c.colors.statusbar.normal.fg = "#89dceb"
c.colors.statusbar.passthrough.fg = "#89dceb"
c.colors.statusbar.url.fg = "#f5c2e7"
c.colors.statusbar.url.success.https.fg = "#a6e3a1"
c.colors.statusbar.url.hover.fg = "#cba6f7"
c.colors.tabs.even.bg = "#1e1e2e"
c.colors.tabs.odd.bg = "#181825"
c.colors.tabs.bar.bg = "#181825"
c.colors.tabs.even.fg = "#6c7086"
c.colors.tabs.odd.fg = "#6c7086"
c.colors.tabs.selected.even.bg = "#cba6f7"
c.colors.tabs.selected.odd.bg = "#cba6f7"
c.colors.tabs.selected.even.fg = "#1e1e2e"
c.colors.tabs.selected.odd.fg = "#1e1e2e"
c.colors.hints.bg = "#f9e2af"
c.colors.hints.fg = "#1e1e2e"
c.tabs.show = "multiple"
c.colors.completion.item.selected.match.fg = "#89dceb"
c.colors.completion.match.fg = "#89dceb"
c.colors.tabs.indicator.start = "#a6e3a1"
c.colors.tabs.indicator.stop = "#45475a"
c.colors.completion.odd.bg = "#1e1e2e"
c.colors.completion.even.bg = "#181825"
c.colors.completion.fg = "#cdd6f4"
c.colors.completion.category.bg = "#181825"
c.colors.completion.category.fg = "#cdd6f4"
c.colors.completion.item.selected.bg = "#313244"
c.colors.completion.item.selected.fg = "#cdd6f4"
c.colors.messages.info.bg = "#1e1e2e"
c.colors.messages.info.fg = "#cdd6f4"
c.colors.messages.error.bg = "#f38ba8"
c.colors.messages.error.fg = "#1e1e2e"
c.colors.downloads.error.bg = "#f38ba8"
c.colors.downloads.error.fg = "#1e1e2e"
c.colors.downloads.bar.bg = "#181825"
c.colors.downloads.start.bg = "#a6e3a1"
c.colors.downloads.start.fg = "#1e1e2e"
c.colors.downloads.stop.bg = "#45475a"
c.colors.downloads.stop.fg = "#cdd6f4"
c.colors.tooltip.bg = "#313244"
c.colors.webpage.bg = "#1e1e2e"
c.hints.border = "#cdd6f4"
c.tabs.title.format = "{audio}{current_title}"
c.fonts.web.size.default = 20
c.tabs.padding = {"top": 5, "bottom": 5, "left": 9, "right": 9}
c.tabs.indicator.width = 0
c.tabs.width = "7%"
c.fonts.default_family = []
c.fonts.default_size = "13pt"
c.fonts.web.family.fixed = "monospace"
c.fonts.web.family.sans_serif = "monospace"
c.fonts.web.family.serif = "monospace"
c.fonts.web.family.standard = "monospace"
