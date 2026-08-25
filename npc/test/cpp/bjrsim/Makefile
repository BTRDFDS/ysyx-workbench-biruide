.PHONY: bjrsim ifusim
buildBjrsim:
	clang++ bjrsim.cpp -o bjrsim -g
bjrsim:buildBjrsim
	time ./bjrsim
buildIfusim:
	clang++ ifusim.cpp -o ifusim -g
ifusim:buildIfusim
	time ./ifusim
