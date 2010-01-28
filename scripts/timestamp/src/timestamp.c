#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <stdio.h>

void out_digits(int i) {
  if (i < 10) {
    printf("0%d", i);
  } else
  if (i < 100) {
    printf("%d", i);
  } else {
    printf("99");
  }
}

int main(int argc, char* argv[])
{
  struct timeval now;
  gettimeofday(&now, NULL);
  printf("%ld.", now.tv_sec);
  out_digits((int)now.tv_usec/10000);
  printf("\n");
  return 0;
}
