// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Store a D program compressed inside another D program
// https://github.com/workhorsy/compress-exe

import std.stdio;
import std.path;
import std.array;
import compress_exe;
import compress;


int main(string[] args) {

	// Get a list of all the files to store
	string[] file_names = args[1 .. $];

	// Convert all the file paths to be absolute
	for (int i=0; i<file_names.length; i++) {
		file_names[i] = file_names[i].absolutePath().asNormalizedPath().array;
	}
	//stdout.writefln("!!! file_names:%s", file_names);

	// Generate a D file that contains all the files as compressed blobs
	GenerateWrapper(file_names, CompressionType.Zlib);

	return 0;
}
