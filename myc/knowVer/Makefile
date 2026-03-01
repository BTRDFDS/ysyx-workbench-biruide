run:
	@g++ -dM -E -x c++ /dev/null | grep -E '__cplusplus|__STDCPP_DEFAULT_NEW_ALIGNMENT__'
	@g++ -dM -E -x c++ /dev/null -std=c++20 | grep -E '__cplusplus|__STDCPP_DEFAULT_NEW_ALIGNMENT__'
	@clang++ -dM -E -x c++ /dev/null | grep __cplusplus
	@clang++ -dM -E -x c++ /dev/null -std=c++20  | grep __cplusplus
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