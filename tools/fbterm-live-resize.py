#!/usr/bin/env python3
# Apply the live-resize change to ~/fbterm-src/fbterm-1.7 (run in WSL); git diff gives the patch.
import os, sys
S = os.path.expanduser("~/fbterm-src/fbterm-1.7/src/")

def sub(path, old, new):
    p = S + path; s = open(p).read()
    if s.count(old) != 1:
        sys.exit(f"{path}: expected one match for {old!r}")
    open(p, "w").write(s.replace(old, new))

sub("screen.h", "\tvoid enableScroll(bool enable) { mScrollEnable = enable; }\n",
    "\tvoid enableScroll(bool enable) { mScrollEnable = enable; }\n"
    "\tbool setReserved(u32 reserved);\n")
sub("screen.h", "\tu32 mWidth, mHeight;\n", "\tu32 mWidth, mHeight, mFullHeight;\n")

sub("fbdev.cpp", "\tmHeight -= reserved;\n", "\tmFullHeight = mHeight;\n\tmHeight -= reserved;\n")

sub("screen.cpp", "\tmWidth = mHeight = 0;\n", "\tmWidth = mHeight = mFullHeight = 0;\n")
s = open(S + "screen.cpp").read()
open(S + "screen.cpp", "w").write(s + """
/*
 * Change the strip left free at the bottom (FBTERM_RESERVE_BOTTOM) while
 * running. Only without rotation and with redraw scrolling, which is what a
 * reserved strip uses. Returns true if the number of rows may have changed.
 */
bool Screen::setReserved(u32 reserved)
{
	if (!mFullHeight || mRotateType != Rotate0 || mScrollType != Redraw) return false;
	if (reserved >= mFullHeight) reserved = 0;

	u32 height = mFullHeight - reserved;
	if (height == mHeight || height < FH(1)) return false;

	mHeight = height;
	mRows = mHeight / FH(1);
	fillRect(0, FH(mRows), mWidth, mHeight - FH(mRows), 0);
	return true;
}
""")

sub("fbshellman.h", "\tvoid switchVc(bool enter);\n", "\tvoid switchVc(bool enter);\n\tvoid resize();\n")
s = open(S + "fbshellman.cpp").read()
open(S + "fbshellman.cpp", "w").write(s + """
void FbShellManager::resize()
{
	for (u32 i = 0; i < NR_SHELLS; i++) {
		if (mShellList[i]) mShellList[i]->resize(screen->cols(), screen->rows());
	}

	if (mVcCurrent) {
		redraw(0, 0, screen->cols(), screen->rows());
	}
}
""")

sub("fbterm.cpp", "\tsigaddset(&sigmask, SIGHUP);\n", "\tsigaddset(&sigmask, SIGHUP);\n\tsigaddset(&sigmask, SIGWINCH);\n")
sub("fbterm.cpp", "\tsignal(SIGHUP, sh);\n", "\tsignal(SIGHUP, sh);\n\tsignal(SIGWINCH, sh);\n")
sub("fbterm.cpp", "\tcase SIGCHLD:\n", """\tcase SIGWINCH: {
		/* FBTERM_RESERVE_FILE: re-read the reserved bottom strip (pixels) */
		const char *path = getenv("FBTERM_RESERVE_FILE");
		FILE *f = path ? fopen(path, "r") : 0;
		if (f) {
			unsigned long reserved;
			if (fscanf(f, "%lu", &reserved) == 1 && Screen::instance()->setReserved(reserved)) {
				FbShellManager::instance()->resize();
			}
			fclose(f);
		}
		break;
	}

\tcase SIGCHLD:
""")
sub("fbterm.cpp", "#include <signal.h>\n", "#include <signal.h>\n#include <stdio.h>\n#include <stdlib.h>\n")
print("OK")
