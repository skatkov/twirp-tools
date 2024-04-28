#
#  Rake tasks to manage native gem packages with binary executables
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by Twirp::Tools::Upstream::NATIVE_PLATFORMS) will each contain
#  two files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── protoc-gen-twirp_ruby                  #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── protoc-gen-twirp_ruby              #  the protoc-gen-twirp_ruby binary executable
#
#  The ruby script `exe/protoc-gen-twirp_ruby` is installed into the user's path, and it simply 
#  locates the binary and executes it. Note that this script is required because rubygems requires 
#  that executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  protoc-gen-twirp_ruby-1.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── protoc-gen-twirp_ruby
#     └── x86_64-linux/
#         └── protoc-gen-twirp_ruby
#
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/protoc-gen-twirp_ruby` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:arm64-linux  # Build the aarch64-linux gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all protoc-gen-twirp-ruby binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#

require "rubygems/package"
require "rubygems/package_task"
require "open-uri"
require "zlib"

require_relative "../lib/twirp/tools/upstream"

def download_url(filename)
  "https://github.com/skatkov/protoc-gen-twirp-ruby/releases/download/v#{Twirp::Tools::Upstream::VERSION}/#{filename}"
end

RAILS_GEMSPEC = Bundler.load_gemspec("twirp-tools.gemspec")

gem_path = Gem::PackageTask.new(RAILS_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

exepaths = []
Twirp::Tools::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
  RAILS_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, "protoc-gen-twirp_ruby") # "exe/x86_64-linux/protoc-gen-twirp_ruby"
    exepaths << exepath

    gemspec.platform = platform

    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      URI.open(release_url) do |remote|
        if release_url.end_with?(".gz")
          Zlib::GzipReader.wrap(remote) do |gz|
            Gem::Package::TarReader.new(gz) do |reader|
              reader.seek("protoc-gen-twirp_ruby") do |file|
                File.binwrite(exepath, file.read)
              end
            end
          end
        end
      end
    end
  end
end

desc "Download all protoc-gen-twirp-ruby binaries"
task "download" => exepaths
