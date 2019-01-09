#include <stdio.h>
int main()
{
	char str[30];
	
	printf("Please enter your name: \n");
	scanf("%s", &str);
	
	printf("Your name is: %s\n", str);

	return 0;
}
