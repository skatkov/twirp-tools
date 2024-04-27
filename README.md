This gem wraps twirp plugin for protoc utility, that ships with GRPC's. 

protoc+twirp_ruby is used to generate beatiful ruby dsl out of .proto files.


# Problem
Currently we're using following approach in our production deployment:


```bash
#!/usr/bin/env bash
. dev/env

check_or_install go go
check_or_install protobuf@21 protoc
brew link --overwrite protobuf@21

go install github.com/twitchtv/twirp-ruby/protoc-gen-twirp_ruby@v1.8.0

protoc --twirp_ruby_out=proto/ --ruby_out=proto/ -I proto/ proto/cheddar.proto
```

This requires a homebrew and golang to be present on a machine. This is not a great solution for a regular ruby developer.

## more information
The protoc utility knows that the github.com/twitchtv/twirp-ruby/protoc-gen-twirp_ruby plugin is installed on the system through the PATH environment variable. When you run the protoc command to generate code, it looks for the installed plugins in the directories specified in the PATH environment variable. The protoc-gen-twirp_ruby plugin needs to be installed in one of the directories in the PATH so that protoc can find and use it to generate the Twirp-specific code. Specifically, the steps are:

1. Install the protoc-gen-twirp_ruby plugin by running `go install github.com/twitchtv/twirp-ruby/protoc-gen-twirp_ruby@latest` or by downloading the binary and placing it in a directory in your PATH.
2. Set the PATH environment variable to include the directory where the protoc-gen-twirp_ruby plugin is installed. For example, if you installed it in the `$GOBIN` directory, you would add `$GOBIN` to your PATH.
3. When you run the protoc command with the `--twirp_ruby_out` flag, protoc will look for the protoc-gen-twirp_ruby plugin in the directories specified in your PATH and use it to generate the Twirp-specific Ruby code.


But It's also possible to include plugin, without placing it into a folder defined in PATH. Like the following:
`protoc --twirp_ruby_out=proto/ --ruby_out=proto/ -I proto/ proto/cheddar.proto --plugin=protoc-gen-twirp_ruby`

Using this command line, we can potentially drop a need for golang and homebrew. We can use protoc utility packaged with grpc-tools gem and offer a twirp-tools gem, that will package a ruby plugin required to create a dsl.

# Inspiration:
- gruf - https://github.com/bigcommerce/gruf/blob/main/gruf.gemspec
- grpc-tools - https://github.com/grpc/grpc/tree/master/src/ruby/tools
- litestreap-ruby - https://github.com/fractaledmind/litestream-ruby
