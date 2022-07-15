#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* - - - - - standard library function prototypes - - - - - */
extern int printf(const char *formatString, ...);
extern int rand(void);

/* - - - - - asm functions - - - - - */

/* string utilities */
extern int stringLength(char *string);
extern int findIndexOfChar(char* string, char charToFind);
extern int findIndexOfString(char* haystack, char* needle);
extern void getSubstring(char *stringIn, char *stringOut, int start, int end);
extern void setBytes(void *location, char value, int numBytes);
extern int stringCopy(char *destStr, char *sourceStr);
extern void stringToUppercase(char *string);
extern void stringToLowercase(char *string);
extern int countCharsInString(char *string, char ch);
extern void stringConcat(char *string1, char *string2);
extern void reverseString(char *string);
extern int compareStrings(char *string1, char *string2);

/* - - - array utilities - - - */
extern void reverseArray(void *array, int elementSize, int numElements);
extern void joinArrays(void *array1, void *array2, int array1Length, int array2Length, int elementSize);
extern int searchArray(void *array, int elementSize, int numElements, void *elementToFind);
extern void arrayRemove(void *array, int elementSize, int numElements, int indexToRemove);
extern void arrayCopy(void *destArray, void *sourceArray, int elementSize, int n);
extern void scrambleArray(void *array, int elementSize, int numElements);
extern void printArray(void *array, int elementSize, int numElements, void (*printElementFunction)(void *));

/* - - - algorithms - - - */
int binarySearch(int *array, int size, int target);
void swap(void *a, void *b, int size);
int nsum(int numAddends, ...);
int nmin(int numOperands, ...);
int nmax(int numOperands, ...);
int naverage(int numOperands, ...);

/* - - - sorting algorithms - - - */
void insertionSort(int *array, int size);
void binaryCountingSort(int *array, int size, int bitToSortBy);
void binaryRadixSort(int *array, int size);
void bubbleSort(int *array, int size);

/* - - - miscellaneous utilities - - - */
void randomizeMemory(void *memory, int numBytes);
int getExecutionTime(void (*function)());
void sleep(int milliseconds);
