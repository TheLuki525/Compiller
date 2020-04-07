int i = 0;
while(i < 10)
{
	print("i is equal ");
	print(i);
	print(" ");
	if(i > 5)
	{
		print("i is larger then five ");
		if(i > 7)
		{
			println("and is larger then seven");
		}
		else
		{
			println("and is less or equal seven");
		}
	}
	else
	{
		print("i is not larger then five ");
		if(i > 2)
		{
			println("and is larger then two");
		}
		else
		{
			println("and is less or equal two");
		}
	}
	i = i + 1;
}
println("the end of the loop");
int c = 0;
float f = 0.0;
print("put an integer ");
read(c);
c = 3+c*(3+7)+4+2*5;
print("given number after multiplication by ten plus seventeen is ");
print(c);
println("");
print("put a float ");
read(f);
f = 3.0+f*(3.0+7.0)+4.0+2.0*5.0;
print("given number after multiplication by ten plus seventeen is ");
print(f);
println("");
println("it is time for bubble sorting");
int arr[5];
arr[0] = 5;
arr[1] = 1;
arr[2] = 2;
arr[3] = 3;
arr[4] = 4;
print("the array before sorting");
print(arr[0]);
print(" ");
print(arr[1]);
print(" ");
print(arr[2]);
print(" ");
print(arr[3]);
print(" ");
print(arr[4]);
println("");
i = 0;
int j = 0;
while(i < 5)
{
	int flag = 0;
	while(j < 5 - i)
	{
		if(j == 0)
		{
			if(arr[0] > arr[1])
			{
				int tmp = arr[0];
				arr[0] = arr[1];
				arr[1] = tmp;
				flag = 1;
			}
		}
		if(j == 1)
		{
			if(arr[1] > arr[2])
			{
				int tmp = arr[1];
				arr[1] = arr[2];
				arr[2] = tmp;
				flag = 1;
			}
		}
		if(j == 2)
		{
			if(arr[2] > arr[3])
			{
				int tmp = arr[2];
				arr[2] = arr[3];
				arr[3] = tmp;
				flag = 1;
			}
		}
		if(j == 3)
		{
			if(arr[3] > arr[4])
			{
				int tmp = arr[3];
				arr[3] = arr[4];
				arr[4] = tmp;
				flag = 1;
			}
		}
		j = j + 1;
		if(flag == 0)
		{
			i = 999;
			j = 999;
		}
	}
	i = i + 1;
}
print("the array after sorting");
print(arr[0]);
print(" ");
print(arr[1]);
print(" ");
print(arr[2]);
print(" ");
print(arr[3]);
print(" ");
print(arr[4]);
println("");
float farr[10];
farr[6] = 4.0;
farr[7] = farr[6]+2*3.0;
print("float array ");
print(farr[6]);
print(" ");
print(farr[7]);
println("");
string txt = "zmienna z tekstem bez nowej linii";
print(txt);
println(txt);
