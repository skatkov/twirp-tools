require_relative "upstream"

module Twirp
    module Tools
      module Commands
        DEFAULT_DIR = File.expand_path(File.join(__dir__, "..", "..", "exe"))
        GEM_NAME = "protoc-gen-twirp_ruby"

        # raised when the host platform is not supported by upstream litestream's binary releases
        UnsupportedPlatformException = Class.new(StandardError)

        # raised when the litestream executable could not be found where we expected it to be
        ExecutableNotFoundException = Class.new(StandardError)

        class << self
            def platform
                [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
            end
            
            def executable(exe_path: DEFAULT_DIR)
                if Twirp::Tools::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match_gem?(Gem::Platform.new(p), GEM_NAME) }
                raise UnsupportedPlatformException, <<~MESSAGE
                    protoc-gen-twirp_ruby does not support the #{platform} platform
                MESSAGE
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
                    MESSAGE
                end
        
                exe_file
            end
        end
      end
    end
  end