int y;
int sub(int a, int x)
{
	int result;
	result = a - 1;

	return(result);
}

int add (int x) 
{
	int a;
	int b;
	int c;
	b = getint();
	c = 4;
	a = b * b + -c;
	printint(a);
	b = sub(a);
	a = b-c;
	printint(a);
}

int main()
{

	add();
	
}

