#include <io.h>
#include <ioctl.h>
#include <mount.h>
#include <multiuser.h>
#include <execve.h>
#include <exit.h>

static char argv0[] = "/init";
static char * argv[] = {(void *) 0, (void *) 0};
static char * envp[] = {(void *) 0};

void main (void) {
  /* Assume that we are the init process.
     The only open file descriptors are 0 (stdin), 1 (stdout), 2 (stderr).
   */

  close (0);
  close (1);
  close (2);

  /* From this point on we are unable to output anything.
     Hence whenever an error occurs we will exit, resulting in a kernel panic.
     We use the exit code to differentiate between failures at different steps.
   */

  int ret = mount ("none", "/dev", "devtmpfs", 0, 0);
  if (ret < 0) exit (1);
  ret = mount ("none", "/proc", "proc", 0, 0);
  if (ret < 0) exit (2);
  ret = mount ("none", "/sys", "sysfs", 0, 0);
  if (ret < 0) exit (3);

  /* Rock 4C+ uses ttyS2, but QEMU uses ttyAMA0 */
  fd_t fd0 = open ("/dev/ttyS2", O_RDWR, 0);
  if (fd0 < 0) fd0 = open ("/dev/ttyAMA0", O_RDWR, 0);
  if (fd0 != 0) exit (4);
  fd_t fd1 = dup (fd0);
  if (fd1 != 1) exit (5);
  fd_t fd2 = dup (fd0);
  if (fd2 != 2) exit (6);

  pid_t sid = setsid ();
  if (sid < 0) exit (7);

  ret = ioctl (fd0, TIOCSCTTY, (void *) 1);
  if (ret < 0) exit (8);

  write (fd0, "TTY ready\n", 11);

  argv[0] = argv0;
  execve ("/init", argv, envp);
}
