#include <stdio.h>
int A[11];
int main() {
	int l, k;
	char j;

	// only c++

	l = 2;
	k = 0;

	for (j = 0; j < 11; j++) {
		k = j;
		l += 8;
		k++;
		switch (j) {
		case 1: k = 0; break;
		case 3: k += l; break;
		case 5: k -= l; break;
		case 6: k = 2 * l - k; break;
		default: k--;
		}
		A[j] = k;
	}

	for (j = 0; j < 11; j++)
		printf("%d ", A[j]);
	printf(" - Just C++\n");

	// c++ with standart asm insertion

	l = 2;
	k = 0;

	_asm{
		// 9    :     for (j = 0; j < 11; j++) {

		mov	BYTE PTR j, 0
		jmp	SHORT LN4
	
		LN2:
			movzx	eax, BYTE PTR j
			add	al, 1
			mov	BYTE PTR j, al

		LN4:
			movsx	eax, BYTE PTR j
			cmp	eax, 11
			jge	LN3

		// 10 k = j;

			movsx	eax, BYTE PTR j
			mov	DWORD PTR k, eax

		// 11 l += 8;

			mov	eax, DWORD PTR l
			add	eax, 8
			mov	DWORD PTR l, eax

		// 12 k++;

			mov	eax, DWORD PTR k
			inc	eax
			mov	DWORD PTR k, eax

		// 13   :         switch (j) {

			movzx	eax, BYTE PTR j
			mov	BYTE PTR j, al

			cmp	BYTE PTR j, 1
			je	SHORT LN10

			cmp	BYTE PTR j, 3
			je	SHORT LN11

			cmp	BYTE PTR j, 5
			je	SHORT LN12

			cmp	BYTE PTR j, 6
			je	SHORT LN13

			jmp	SHORT LN14
		
		LN10:

			// 14 case 1: k = 0; break;

			mov	DWORD PTR k, 0
			jmp	SHORT LN5
		
		LN11:

			// 15 case 3: k += l; break;

			mov	eax, DWORD PTR l
			mov	ecx, DWORD PTR k
			add	ecx, eax
			mov	eax, ecx
			mov	DWORD PTR k, eax
			jmp	SHORT LN5

		LN12:

			// 16 case 5: k -= l; break;

			mov	eax, DWORD PTR l
			mov	ecx, DWORD PTR k
			sub	ecx, eax
			mov	eax, ecx
			mov	DWORD PTR k, eax
			jmp	SHORT LN5
	
		LN13:

			// 17 case 6: k = 2 * l - k; break;

			mov	eax, DWORD PTR l
			shl	eax, 1
			sub	eax, DWORD PTR k
			mov	DWORD PTR k, eax
			jmp	SHORT LN5

		LN14:

			// 18   :         default: k--;

			mov	eax, DWORD PTR k
			dec	eax
			mov	DWORD PTR k, eax
	
		LN5:

			// 20 A[j] = k;

			movsx	eax, BYTE PTR j
			mov	ecx, DWORD PTR k
			mov	DWORD PTR A[eax * 4], ecx
			jmp	LN2
	
		LN3:
	}

    for (j = 0; j < 11; j++)
        printf("%d ", A[j]);
    printf(" - C++ with standart asm insertion\n");

	//l = 2;
	//k = 0;

	//_asm {
	//	// 9 for (j = 0; j < 11; j++) {
	//	mov	BYTE PTR j, 0
	//	jmp	SHORT LN4
	//	LN2 :
	//		movzx	eax, BYTE PTR j
	//		inc	al
	//		mov	BYTE PTR j, al
	//	LN4 :
	//		movsx	eax, BYTE PTR j
	//		cmp	eax, 11
	//		jge	LN3
	//		// 10 k = j;
	//		movsx	eax, BYTE PTR j
	//		mov	DWORD PTR k, eax
	//		// 11 l += 8;
	//		add	l, 8
	//		// 12 k++;
	//		mov	eax, DWORD PTR k
	//		inc	eax
	//		mov	DWORD PTR k, eax
	//		// 13 switch (j) {
	//		cmp	BYTE PTR j, 1
	//		je	SHORT LN10
	//		cmp	BYTE PTR j, 3
	//		je	SHORT LN11
	//		cmp	BYTE PTR j, 5
	//		je	SHORT LN12
	//		cmp	BYTE PTR j, 6
	//		je	SHORT LN13
	//		jmp	SHORT LN14
	//	LN10 :
	//		// 14 case 1: k = 0; break;
	//		mov	DWORD PTR k, 0
	//		jmp	SHORT LN5
	//	LN11 :
	//		// 15 case 3: k += l; break;
	//		mov	eax, DWORD PTR l
	//		mov	ecx, DWORD PTR k
	//		add	ecx, eax
	//		mov	DWORD PTR k, ecx
	//		jmp	SHORT LN5
	//	LN12 :
	//		// 16 case 5: k -= l; break;
	//		mov	eax, DWORD PTR l
	//		mov	ecx, DWORD PTR k
	//		sub	ecx, eax
	//		mov	DWORD PTR k, ecx
	//		jmp	SHORT LN5
	//	LN13 :
	//		// 17 case 6: k = 2 * l - k; break;
	//		mov	eax, DWORD PTR l
	//		shl	eax, 1
	//		sub	eax, DWORD PTR k
	//		mov	DWORD PTR k, eax
	//		jmp	SHORT LN5
	//	LN14 :
	//		// 18 default: k--;
	//		dec DWORD PTR k
	//	LN5 :
	//		// 20 A[j] = k;
	//		movsx	eax, BYTE PTR j
	//		mov	ecx, DWORD PTR k
	//		mov	DWORD PTR[A + eax * 4], ecx
	//		jmp	LN2
	//	LN3 :
	//}

	//for (j = 0; j < 11; j++)
	//	printf("%d ", A[j]);
	//printf(" - C++ with optimized asm insertion\n");

    return 0;
}
