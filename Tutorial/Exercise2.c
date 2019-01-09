#include <stdio.h>
#include <string.h>

int main()
{
	char s[6] = "Hello";
	char t [6] = "World";
	strcpy(s+5,t);
	printf("%s\n", s);

	return 0;
}
	
