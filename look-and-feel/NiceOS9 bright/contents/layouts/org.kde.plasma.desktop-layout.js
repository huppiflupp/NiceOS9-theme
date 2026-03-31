var plasma = getApiVersion(1);

// Set wallpaper on all desktops across all screens
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    allDesktops[i].wallpaperPlugin = "org.kde.image";
    allDesktops[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    allDesktops[i].writeConfig("Image", "file://HOME_PLACEHOLDER/.local/share/plasma/look-and-feel/NiceOS9 bright/contents/wallpaper/Sage-Foam.jpg");
    allDesktops[i].reloadConfig();
}

// Panel
var panel = new Panel;
panel.location = "top";
panel.height = 32;
panel.floating = false;
panel.hiding = "none";
panel.alignment = "center";

var geo = screenGeometry(panel.screen);
panel.minimumLength = geo.width;
panel.maximumLength = geo.width;

panel.addWidget("org.kde.plasma.kickoff");
panel.addWidget("org.kde.plasma.icontasks");
panel.addWidget("org.kde.plasma.panelspacer");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
