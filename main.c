#include <io.h>
#include <ioctl.h>
#include <mount.h>
#include <multiuser.h>
#include <execve.h>
#include <exit.h>

char * const argv[] = {"/init", (void *) 0};
char * const envp[] = {(void *) 0};

void main (void) {
  /* Assume that we are the init process.
     The only open file descriptors are 0 (stdin), 1 (stdout), 2 (stderr).
   */

  close (0);
  close (1);
  close (2);

  /* From this point on we are unable to output anything.
     Hence whenever an error occurs we will exit, resulting in a kernel panic.
   */

  int ret = mount ("none", "/dev", "devtmpfs", 0, 0);
  if (ret < 0) exit (0);
  ret = mount ("none", "/proc", "proc", 0, 0);
  if (ret < 0) exit (0);
  ret = mount ("none", "/sys", "sysfs", 0, 0);
  if (ret < 0) exit (0);

  fd_t fd0 = open ("/dev/ttyAMA0", O_RDWR, 0);
  if (fd0 != 0) exit (0);
  fd_t fd1 = dup (fd0);
  if (fd1 != 1) exit (0);
  fd_t fd2 = dup (fd0);
  if (fd2 != 2) exit (0);

  pid_t sid = setsid ();
  if (sid < 0) exit (0);

  ret = ioctl (fd0, TIOCSCTTY, (void *) 1);
  if (ret < 0) exit (0);

  write (fd0, "TTY ready\n", 11);
  execve ("/init", argv, envp);
}
