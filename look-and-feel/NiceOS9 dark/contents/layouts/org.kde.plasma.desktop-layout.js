var plasma = getApiVersion(1);

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
