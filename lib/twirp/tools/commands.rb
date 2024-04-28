require_relative "upstream"

module Twirp
    module Tools
      module Commands
        DEFAULT_DIR = File.expand_path(File.join(__dir__, "..", "..", "..", "exe"))
        GEM_NAME = "protoc-gen-twirp_ruby"

        # raised when the host platform is not supported
        UnsupportedPlatformException = Class.new(StandardError)

        # raised when executable could not be found
        ExecutableNotFoundException = Class.new(StandardError)

        class << self
            def platform
                [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
            end
            
            def executable(exe_path: DEFAULT_DIR)
                if Twirp::Tools::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match_gem?(Gem::Platform.new(p), GEM_NAME) }
                    raise UnsupportedPlatformException, "protoc-gen-twirp_ruby does not support the #{platform} platform"
                end
    
                exe_file = Dir.glob(File.expand_path(File.join(exe_path, "*", "protoc-gen-twirp_ruby"))).find do |f|
                    Gem::Platform.match_gem?(Gem::Platform.new(File.basename(File.dirname(f))), GEM_NAME)
                end
            
                if exe_file.nil? || !File.exist?(exe_file)
                    raise ExecutableNotFoundException, <<~MESSAGE
                    Cannot find the protoc-gen-twirp_ruby executable for #{platform} in #{exe_path}
        
                    If you're using bundler, please make sure you're on the latest bundler version:
        
                        gem install bundler
                        bundle update --bundler
        
                    Then make sure your lock file includes this platform by running:
        
                        bundle lock --add-platform #{platform}
                        bundle install
        
                    See `bundle lock --help` output for details.

                    If none of the above helps, it might be that executable for your platform doesn't exist,
                    in this case please report this issue at https://github.com/skatkov/protoc-gen-twirp-ruby
                    MESSAGE
                end
        
                exe_file
            end
        end
      end
    end
  end