// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Store a D program compressed inside another D program
// https://github.com/workhorsy/compress-exe

module compress;

import std.stdio;
import std.file;

version (linux) {
	immutable string Exe7Zip = "7za";
	immutable string ExeUnrar = "unrar";
}
version (Windows) {
	immutable string Exe7Zip = "7za.exe";
	immutable string ExeUnrar = "unrar.exe";
}

enum CompressionType {
	Zlib,
	Lzma,
}

ubyte[] ToCompressed(ubyte[] blob, CompressionType compression_type) {
	final switch (compression_type) {
		case CompressionType.Lzma:
			import std.algorithm;
			import std.array;
			import std.process;
			import std.string;
			import std.path;

			string blob_file = [std.file.tempDir(), "blob"].join(std.path.dirSeparator);
			string zip_file = [std.file.tempDir(), "blob.7z"].join(std.path.dirSeparator);
/*
			stdout.writefln("blob_file; %s", blob_file);
			stdout.writefln("zip_file; %s", zip_file);
*/

			// Write the blob to file
			std.file.write(blob_file, blob);

			// Get the command and arguments
			const string[] command = [
				"tools/" ~ Exe7Zip,
				"a",
				"-t7z",
				"-m0=lzma2",
				"-mx=9",
				"%s".format(zip_file),
				"%s".format(blob_file),
			];

			// Run the command and wait for it to complete
			auto pid = spawnProcess(command);
			int status = wait(pid);
		/*
			string[] result_stdout = pipes.stdout.byLine.map!(l => l.idup).array();
			string[] result_stderr = pipes.stderr.byLine.map!(l => l.idup).array();
			stdout.writefln("!!! stdout:%s", result_stdout);
			stdout.writefln("!!! stderr:%s", result_stderr);
		*/
			if (status != 0) {
				stderr.writefln("Failed to run command: %s\r\n", Exe7Zip);
			}

			// Read the compressed blob from file
			ubyte[] file_data = cast(ubyte[]) std.file.read(zip_file);

			// Delete the temp files
			std.file.remove(blob_file);
			std.file.remove(zip_file);

			return file_data;
	case CompressionType.Zlib:
		import std.zlib;
		ubyte[] zlibed_data = std.zlib.compress(blob, 9);
		return zlibed_data;
	}
}

ubyte[] ToCompressedBase64(T)(T thing, CompressionType compression_type) {
	import std.array : appender;
	import cbor;
	import std.base64;

	// Convert the thing to a blob
	auto buffer = appender!(ubyte[])();
	encodeCbor(buffer, thing);
	ubyte[] blob = buffer.data;

	// Compress the blob
	ubyte[] compressed_bob = ToCompressed(blob, compression_type);

	// Base64 the compressed blob
	ubyte[] base64ed_compressed_blob = cast(ubyte[]) Base64.encode(compressed_bob);

	return base64ed_compressed_blob;
}

ubyte[] FromCompressed(ubyte[] data, CompressionType compression_type) {
	final switch (compression_type) {
		case CompressionType.Lzma:
			return [];
		case CompressionType.Zlib:
			import std.zlib;
			ubyte[] blob = cast(ubyte[]) std.zlib.uncompress(data);
			return blob;
	}
}

T FromCompressedBase64(T)(ubyte[] data, CompressionType compression_type) {
	import cbor;
	import std.array : appender;
	import std.base64;

	// UnBase64 the blob
	ubyte[] compressed_blob = cast(ubyte[]) Base64.decode(data);

	// Uncompress the blob
	ubyte[] blob = FromCompressed(compressed_blob, compression_type);

	// Convert the blob to the thing
	T thing = decodeCborSingle!T(blob);
	return thing;
}

void UncompressFile(string compressed_file, string out_dir) {
	import std.algorithm;
	import std.string;
	import std.process;
	import std.array;

	string[] command;

	if (compressed_file.endsWith(".7z") || compressed_file.endsWith(".zip")) {
		// Get the command and arguments
		command = [
			Exe7Zip,
			"x",
			"-y",
			`%s`.format(compressed_file),
			"-o%s".format(out_dir),
		];
	} else if (compressed_file.endsWith(".rar")) {
		// Get the command and arguments
		command = [
			ExeUnrar,
			"x",
			"-y",
			`%s`.format(compressed_file),
			"%s".format(out_dir),
		];
	} else {
		throw new Exception("Uknown file type to uncompress: %s".format(compressed_file));
	}

	// Run the command and wait for it to complete
	auto pid = spawnProcess(command);
	int status = wait(pid);
/*
	string[] result_stdout = pipes.stdout.byLine.map!(l => l.idup).array();
	string[] result_stderr = pipes.stderr.byLine.map!(l => l.idup).array();
	stdout.writefln("!!! stdout:%s", result_stdout);
	stdout.flush();
	stdout.writefln("!!! stderr:%s", result_stderr);
	stdout.flush();
*/
	if (status != 0) {
		stderr.writefln("Failed to run command: %s", command);
	}
}
