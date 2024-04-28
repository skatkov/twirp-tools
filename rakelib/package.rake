require "rubygems/package"
require "rubygems/package_task"
require "open-uri"
require "zlib"

def litestream_download_url(filename)
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
      release_url = litestream_download_url(filename)
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

desc "Download all litestream binaries"
task "download" => exepaths
