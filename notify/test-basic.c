#include <libnotify/notify.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char * argv[] ) 
{
    NotifyNotification *n;  

    notify_init("Basics");

    n = notify_notification_new ("Summary", 
                                 "This is the message that we want to display",
                                  NULL, NULL);
    notify_notification_set_timeout (n, 5000); // 5 seconds

    if (!notify_notification_show (n, NULL)) 
    {
	fprintf(stderr, "failed to send notification\n");
	return 1;
    }

    g_object_unref(G_OBJECT(n));

    return 0;
}
