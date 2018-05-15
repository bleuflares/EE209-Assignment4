## Enumerated constants
##each are ascii value corresponding to each characters
.equ   ARRAYSIZE, 20
.equ   EOF, -1
.equ   q, 'q'
.equ   p, 'p'
.equ   f, 'f'
.equ   c, 'c'
.equ   d, 'd'
.equ   r, 'r'
.equ   plus, '+'
.equ   minus, '-'
.equ   multi, '*'
.equ   div, '/'
.equ   mod, '%'
.equ   power, '^'
.equ   underbar, '_'

## strings to be printed for each cases
cEmpty:
	.asciz "dc: stack empty \n"
cInt:
	.asciz "%d \n"
cError:
	.asciz "dc: invalid input error \n"
cZeroDiv:
	.asciz "dc: divide by zero; invalid \n"
cNegexp:
	.asciz "dc: do not support negative exponent \n"
.section ".rodata"

scanfFormat:
	.asciz "%s"

.section ".data"

.section ".bss"

buffer:
	.skip  ARRAYSIZE

.section ".text"


## int main(void)
## Runs desk calculator program.  Returns 0.

.globl  main
.type   main, @function


main:
	pushl   %ebp
	movl    %esp, %ebp

## dc number stack initialized. %esp = %ebp
## check if user input EOF 
##  if not, store the address of buffer @%edi
##	if (scanf("%s", buffer) == EOF)
##		goto quit;
##	else
##	{	int sign=1;
##		int *arg=&buffer;
##	}
start: 
	pushl	$buffer
	pushl	$scanfFormat
	call    scanf
	addl    $8, %esp
	cmp	$EOF, %eax
	je	quit
	movl $1, %esi
	movl $buffer, %edi

## check if the first character of input is digit
## 	if (!isdigit(buffer[0]))
DigitCheck:
	movl (%edi), %ebx
	movzbl %bl, %ebx
	push %ebx
	call isdigit
	addl $4, %esp
	test %eax, %eax
	jne digit

## check if the first character of input is p
## print the value on top of the stack
## print "dc: stack empty" if the stack is empty
##		if (buffer[0] == 'p') {
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##			} else {
##				printf("%d\n", (int)stack.top());
##		}
Pcheck:
	cmp $p, %ebx
	jne Qcheck
	cmp %ebp, %esp
	je print
	pushl $cInt
	call printf
	addl $4, %esp
	jmp start

##	print "dc: stack empty"
##  will be used many times in other parts of the code
##	printf("dc: stack empty\n");
print:
	pushl $cEmpty
	call printf
	addl $4, %esp
	jmp start

## check if the first character of input is q and return if true
##		else if (buffer[0] == 'q')
##			goto quit;
Qcheck:
	cmp $q, %ebx
	je quit


## check if the first character of input is f and store %esp @%esi if true
##		else if (buffer[0] == 'f')
##			temp=stack.peek()
Fcheck:
	cmp $f, %ebx
	jne Ccheck
	movl %esp, %esi

## print the the values stored on stack in LIFO order and restore after print
## while (arg!=NULL)
## {
##	printf("%d\n", *arg);
##	arg++
## }
## arg=temp;
F:
	cmp %ebp, %esi
	je start
	pushl (%esi)
	pushl $cInt
	call printf
	addl $8, %esp
	addl $4, %esi
	jmp F

## check if the first character of input is c
##		else if (buffer[0] == 'c')
Ccheck:
	cmp $c, %ebx
	jne Dcheck

##clear the stack using pop
## while stack.peek()!=NULL
##		stack.pop()
C:
	cmp %ebp, %esp
	je start
	popl %eax
	jmp C

## check if the first character of input is d
## if the stack is not empty, duplicate the value on top of the stack
##		else if (buffer[0] == 'd'){
##			if(stack.peek()!=NULL){
##				temp=stack.top();
##				stack.push(temp);
##			}
##		}
Dcheck:
	cmp $d, %ebx
	jne Rcheck
	cmp %ebp, %esp
	je print
	movl (%esp), %edi
	pushl %edi
	jmp start

## check if the first character of input is r
##		else if (buffer[0] == 'r'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}

Rcheck:
	cmp $r, %ebx
	jne PlusCheck	
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne R
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## pop the second argument and push in reverse order
##			b = (int)stack.pop();
##			stack.push(b);
##			stack.push(a);
R:
	popl %esi
	pushl %edi
	pushl %esi
	jmp start

## check if the first character of input is +
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '+'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
PlusCheck:
	cmp $plus, %ebx
	jne MinusCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne Plus
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## pop the second argument
## push the addition of two arguments
##			b = (int)stack.pop();
##			res = b+a;
## 			stack.push(res);
Plus:
	popl %esi
	movl %esi, %eax
	addl %edi, %eax
	pushl %eax
	jmp start

## check if the first character of input is -
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '-'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
MinusCheck:
	cmp $minus, %ebx
	jne MultiCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne Minus
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## pop the second argument
## push the subtraction of two arguments
##			b = (int)stack.pop();
##			res = b-a;
## 			stack.push(res);
Minus:
	popl %esi
	movl %esi, %eax
	subl %edi, %eax
	pushl %eax
	jmp start

## check if the first character of input is *
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '*'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
MultiCheck:
	cmp $multi, %ebx
	jne DivCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne Multi
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## pop the second argument
## push the multiplication of two arguments
##			b = (int)stack.pop();
##			res = b*a;
## 			stack.push(res);
Multi:
	popl %esi
	movl %esi, %eax
	imull %edi, %eax
	pushl %eax
	jmp start


## check if the first character of input is /
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '/'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
DivCheck:
	cmp $div, %ebx
	jne ModCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp $0, %edi
	je ZeroDiv
	cmp %ebp, %esp
	jne Div
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## check if the first argument is zero
## print error message when it is zero
## pop the second argument
## push the quotient of division
##			else if(a==0)
##				printf("dc: divide by zero; invalid \n")
##			else
##			{
##				b = (int)stack.pop();
##				res = b/a;
## 				stack.push(res);
##			}
Div:
	popl %edx
	movl %edx, %eax
	sarl $31, %edx
	idivl %edi
	pushl %eax
	jmp start



## check if the first character of input is %
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '%'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
ModCheck:
	cmp $mod, %ebx
	jne PowCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne Mod
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## check if the first argument is zero
## print error message when it is zero
## pop the second argument
## push the remainder of division
##			else if(a==0)
##				printf("dc: divide by zero; invalid \n")
##			else
##			{
##				b = (int)stack.pop();
##				res = b%a;
## 				stack.push(res);
##			}
Mod:
	cmp $0, %edi
	je ZeroDiv
	popl %edx
	movl %edx, %eax
	sarl $31, %edx
	idivl %edi
	pushl %edx
	jmp start

## print error message when trying to divide by zero
##		printf("dc: divide by zero; invalid \n")
##		stack.push(a);
ZeroDiv:
	pushl $cZeroDiv
	call printf
	addl $4, %esp
	push %edi
	jmp start

## check if the first character of input is ^
## pop the first argument if the stack is not empty
## restore the first argument if the stack is empty after pop
##		else if (buffer[0] == '^'){
##			int a, b;
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				continue;
##			}
##			a = (int)stack.pop();
##			if (stack.peek() == NULL) {
##				printf("dc: stack empty\n");
##				stack.push(a);
##				continue;
##			}
##		}
PowCheck:
	cmp $power, %ebx
	jne NegCheck
	cmp %ebp, %esp
	je print
	popl %edi
	cmp %ebp, %esp
	jne Pow
	pushl $cEmpty
	call printf
	addl $4, %esp
	push %edi
	jmp start

## pop the second argument
## push the result of power
##			if(a<0){
##				printf("dc: do not support negative exponent \n")
##				stack.push(a);
##			}
##			else{
##				b = (int)stack.pop();
##				res=1;
##				while(a!=0)
##				{
##					res*b;
##					a--;
##				}
## 				stack.push(res);
##			}
Pow:
	cmp $0, %edi
	jge PowStart
	pushl $cNegexp
	call printf
	addl $4, %esp
	push %edi
	jmp start
PowStart:
	popl %esi
	movl $1, %eax
PowLoop:
	cmp $0, %edi
	je PowEnd
	imul %esi, %eax
	subl $1, %edi
	jmp PowLoop
PowEnd:
	pushl %eax
	jmp start

## check if the first character of input is _
## increment the argument pointer
## set the sign to -1
##		else if (buffer[0] == '_'){
##			arg++;
##			sign=-1;
##			goto DigitCheck;
##		}

NegCheck:
	cmp $underbar, %ebx
	jne error
	movl $buffer, %edi
	addl $1, %edi
	movl $0xffffffff, %esi
	jmp DigitCheck

##		convert the string to number
##		apply sign and push to stack	
##		int no = atoi(buffer);
##		no *=sign;
##		stack.push(no);
digit:
	movl %edi, %eax
	pushl %eax
	call atoi
	addl $4, %esp
	imull %esi, %eax
	pushl %eax
	jmp start

## first character does not matches any valid argument
## print string "dc: invalid input error \n"
##		else
##			printf("dc: invalid input error \n")
error:
	pushl $cError
	call printf
	addl $4, %esp
	jmp start

## return of main function
## return 0;
quit:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
