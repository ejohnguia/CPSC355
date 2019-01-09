#include<stdio.h>

int main()
{
	char str[30];

	printf("Please enter a string:\n");
	int i = 0;

	while ((str[i++] = getchar()) != '\n');

	i = 0;
	printf("the string you entered is: \n");
	while (putchar(str[i++]) != '\n');

	return 0;
}
