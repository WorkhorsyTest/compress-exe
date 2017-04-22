// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Store a D program compressed inside another D program
// https://github.com/workhorsy/compress-exe


import compress_exe;
import compress;


int main() {
	// Get a list of all the files to store
	string[] file_names = [
		"README.md",
	];

	// Generate a D file that contains all the files as compressed blobs
	GenerateWrapper(file_names, CompressionType.Zlib);

	return 0;
}
