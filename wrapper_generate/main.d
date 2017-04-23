// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Store a D program compressed inside another D program
// https://github.com/workhorsy/compress-exe

import std.stdio;
import std.path;
import std.array;
import std.json;
import std.file;
import std.string;
import compress_exe;
import compress;


int main(string[] args) {
	stdout.writefln("!!! args:%s", args);

	// Get the json file absolute path
	string json_file_name = args[1].absolutePath().asNormalizedPath().array;
	if (! std.file.exists(json_file_name)) {
		throw new Exception("No such json file: \"%s\"".format(json_file_name));
	}

	// Load the json file
//	try {
		auto data = std.file.readText(json_file_name);
		JSONValue json = parseJSON(data);
		auto json_obj = json.object();

		string start_exe_name = json_obj["start_exe_name"].str;
		string wrapper_exe_name = json_obj["wrapper_exe_name"].str;
		string[string] additional_files;
		foreach (k, v ; json_obj["additional_files"].object()) {
			additional_files[k] = v.str;
		}
		stdout.writefln("!!! start_exe_name:%s", start_exe_name);
		stdout.writefln("!!! wrapper_exe_name:%s", wrapper_exe_name);
		stdout.writefln("!!! additional_files:%s", additional_files);
//	} catch (Throwable) {

//	}

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
