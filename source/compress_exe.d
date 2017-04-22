// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Store a D program compressed inside another D program
// https://github.com/workhorsy/compress-exe

module compress_exe;

import std.stdio;
import std.file;
import compress;


void UncompressFiles(string[] file_names, ubyte[] compressed_blobs) {
	import std.file;
	import std.stdio;
	stdout.writefln("file_names:%s", file_names);

	// Uncompress the file blobs
	ubyte[] blob = cast(ubyte[]) compressed_blobs;
	ubyte[][] file_blobs = FromCompressedBase64!(ubyte[][])(blob, CompressionType.Zlib);

	// Copy the blobs to files
	foreach (i, file_name ; file_names) {
		stdout.writefln("name:%s, length:%s", file_name, file_blobs[i].length);
		std.file.write(file_name, file_blobs[i]);
	}
}

void GenerateWrapper(string[] file_names, CompressionType compression_type) {
	//std.file.chdir("../..");

	// Generate a file that will contain everything
	auto output = std.stdio.File("wrapped.d", "w");
	scope (exit) output.close();

	// Read the files into an array
	ubyte[][] file_blobs;
	foreach (file_name ; file_names) {
		// Read the file to a string
		file_blobs ~= cast(ubyte[]) std.file.read(file_name);
	}

	// Convert the array to a compressed blob
	ubyte[] compressed_blobs = ToCompressedBase64(file_blobs, CompressionType.Zlib);

	// Write the files generating function
	output.write("\r\n\r\n");
	output.write("static immutable string[] g_file_names = \r\n");
	output.write(file_names);
	output.write(";\r\n\r\n");

	output.write("static immutable ubyte[] g_compressed_blobs = \r\n");
	output.write(compressed_blobs);
	output.write(";\r\n\r\n");

	output.write("int main() {\r\n");
	output.write("	import compress_exe;\r\n");
	output.write("\r\n");
	output.write("	string[] file_names = cast(string[]) g_file_names;\r\n");
	output.write("	ubyte[] blob = cast(ubyte[]) g_compressed_blobs;\r\n");
	output.write("	compress_exe.UncompressFiles(file_names, blob);\r\n");
	output.write("\r\n");
	output.write("	return 0;\r\n");
	output.write("}\r\n");
}
