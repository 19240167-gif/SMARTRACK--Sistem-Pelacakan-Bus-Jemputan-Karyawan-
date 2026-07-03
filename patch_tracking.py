with open("lib/screens/karyawan/tracking_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix prefer_const - add const to Positioned top bar
content = content.replace(
    "          // -- Top bar -------------------------------------------------------\n          Positioned(\n            top: 0,\n            left: 0,\n            right: 0,",
    "          // -- Top bar\n          Positioned(\n            top: 0,\n            left: 0,\n            right: 0,"
)

# GlassCard with const padding -> const GlassCard
content = content.replace(
    "                    GlassCard(\n                      padding: const EdgeInsets.all(10),\n                      borderRadius: 12,\n                      child: const Icon(\n                        Icons.arrow_back_ios_rounded,\n                        color: AppColors.textPrimary,\n                        size: 20,\n                      ),\n                    ),",
    "                    const GlassCard(\n                      padding: EdgeInsets.all(10),\n                      borderRadius: 12,\n                      child: Icon(\n                        Icons.arrow_back_ios_rounded,\n                        color: AppColors.textPrimary,\n                        size: 20,\n                      ),\n                    ),"
)

content = content.replace(
    "                    GlassCard(\n                      padding: const EdgeInsets.all(10),\n                      borderRadius: 12,\n                      child: const Icon(Icons.layers_rounded,\n                          color: AppColors.textPrimary, size: 20),\n                    ),",
    "                    const GlassCard(\n                      padding: EdgeInsets.all(10),\n                      borderRadius: 12,\n                      child: Icon(Icons.layers_rounded,\n                          color: AppColors.textPrimary, size: 20),\n                    ),"
)

# Fix TAMPILAN DEMO Positioned - add const
content = content.replace(
    "          // -- Label \"PROTOTYPE / DEMO\" watermark ---------------------------\n          Positioned(\n            top: 100,",
    "          // -- DEMO watermark\n          Positioned(\n            top: 100,"
)

# Fix the Positioned for zoom controls
content = content.replace(
    "          // -- Zoom controls (gimmik) ----------------------------------------\n          Positioned(\n            right: 16,\n            bottom: 200,",
    "          // -- Zoom controls\n          Positioned(\n            right: 16,\n            bottom: 200,"
)

# Fix AnimatedStatusBadge('Dalam Perjalanan') not const but the surrounding Column/Row
content = content.replace(
    "              loading: () => const GlassCard(\n                margin: EdgeInsets.all(16),\n                child: Row(\n                  children: [\n                    SizedBox(\n                      width: 24,\n                      height: 24,\n                      child: CircularProgressIndicator(\n                          strokeWidth: 2, color: AppColors.accent),\n                    ),\n                    SizedBox(width: 12),\n                    Text('Mencari lokasi bus...',\n                        style: TextStyle(color: AppColors.textSecondary)),\n                  ],\n                ),\n              ),",
    "              loading: () => const GlassCard(\n                margin: EdgeInsets.all(16),\n                child: Row(\n                  children: [\n                    SizedBox(\n                      width: 24,\n                      height: 24,\n                      child: CircularProgressIndicator(\n                          strokeWidth: 2, color: AppColors.accent),\n                    ),\n                    SizedBox(width: 12),\n                    Text('Mencari lokasi bus...',\n                        style: TextStyle(color: AppColors.textSecondary)),\n                  ],\n                ),\n              ),"
)

# Fix line 283 prefer_const for _buildDemoCard inner widget
# Find line 283-285 area
lines = content.split('\n')
for i, line in enumerate(lines[275:295], start=276):
    print(f'{i}: {line}')

with open("lib/screens/karyawan/tracking_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
