run:
	clang++ check_cpp_version.cpp -o test -std=c++17
	./test
	clang++ check_cpp_version.cpp -o test -std=c++20
	./test
	g++ check_cpp_version.cpp -o test -std=c++17
	./test
	g++ check_cpp_version.cpp -o test -std=c++20
	./test
clean:
	rm -f test