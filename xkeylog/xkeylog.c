#include <X11/Xlib.h>
#include <sys/time.h>
#include <stdio.h>
#include <unistd.h>

typedef char Keymap[32];

void CompareKeymaps(Display *dpy, const Keymap k1, const Keymap k2)
{
    int i, j;
    struct timeval tv;
    gettimeofday(&tv, NULL);
    for(i = 0; i != 32; ++i)
    {
        char d = k1[i] &~ k2[i];
        char p = k2[i] &~ k1[i];
	int k;
        for(j = 0, k = 1; j != 8; ++j, k <<= 1)
        {
	    if (p & k) {
		printf("%d.%06d:p:%d\n", tv.tv_sec, tv.tv_usec, 8*i+j);
	    }
	    if (d & k) {
		printf("%d.%06d:r:%d\n", tv.tv_sec, tv.tv_usec, 8*i+j);
	    }
        }
    }
    fflush(stdout);
}

int main()
{
    Keymap k1 = {0};
    Keymap k2 = {0};
    Display *dpy = XOpenDisplay(0);
    if(!dpy)
        err(1, "don't have a display, cu\n");
    for(;;)
    {
	usleep(1000);
        XQueryKeymap(dpy, k1);
        CompareKeymaps(dpy, k2, k1);
	usleep(1000);
        XQueryKeymap(dpy, k2);
        CompareKeymaps(dpy, k1, k2);
    }
}
