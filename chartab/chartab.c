int main (int argc, char **argv) {
	int i;
	for (i = 0; i < 256; i++) {
		printf ("%x %o %c\t", i, i, i);
		if (i % 8 == 7) printf ("\n");
	}
	return 0;
}
