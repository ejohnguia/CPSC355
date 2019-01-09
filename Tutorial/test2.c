#include <stdio.h>
#include <string.h>

int main()
{
	char s[10] = "";
	char t[10] = "hello";
	printf("s is %s\n", s);
	printf("t is %s\n", t);
	/*copy t into s*/
	strcpy(s,t);
	printf("s is %s\n", s);
	printf("t is %s\n", t);
	return 0;
}
