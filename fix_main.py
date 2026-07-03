with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# -- 1. Background browser: biru gelap ? putih bersih --------------------------
old_bg = """          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.05,
                colors: [
                  Color(0xFF102C62),
                  Color(0xFF071735),
                  Color(0xFF030817),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
            ),
            child: Stack(
              children: [
                const _AmbientBlob(
                    alignment: Alignment(-0.45, -0.75),
                    color: Color(0xFF2563EB),
                    size: 310),
                const _AmbientBlob(
                    alignment: Alignment(0.55, 0.72),
                    color: Color(0xFF14B8A6),
                    size: 250),
                Center("""

new_bg = """          return DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
            ),
            child: Stack(
              children: [
                Center("""

content = content.replace(old_bg, new_bg)

# -- 2. Frame HP: gradient biru/multi-warna ? hitam titanium seperti iPhone ----
old_frame = """          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF94A3B8),
                  Color(0xFF1E3A8A),
                  Color(0xFF020617),
                  Color(0xFF38BDF8),
                ],
                stops: [0.0, 0.22, 0.72, 1.0],
              ),
              borderRadius: BorderRadius.circular(52),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.58),
                  blurRadius: 44,
                  offset: const Offset(0, 28),
                ),
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.26),
                  blurRadius: 78,
                  spreadRadius: 2,
                ),
              ],
            ),"""

new_frame = """          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6B7280),
                  Color(0xFF374151),
                  Color(0xFF111827),
                  Color(0xFF4B5563),
                ],
                stops: [0.0, 0.28, 0.72, 1.0],
              ),
              borderRadius: BorderRadius.circular(52),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 80,
                  spreadRadius: 4,
                ),
              ],
            ),"""

content = content.replace(old_frame, new_frame)

# -- 3. Hapus _AmbientBlob karena sudah tidak dipakai (background putih) --------
#  Hapus class _AmbientBlob seluruhnya
import re
content = re.sub(
    r'\nclass _AmbientBlob extends StatelessWidget \{.*?\n\}\n',
    '\n',
    content,
    flags=re.DOTALL
)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Done")
