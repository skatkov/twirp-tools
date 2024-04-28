module Twirp
    module Tools
        module Upstream
            VERSION = "1.11.0" # there is only one version now.

            NATIVE_PLATFORMS = {
            "arm64-darwin" => "protoc-gen-twirp_ruby-#{VERSION}-darwin-arm64.tar.gz",
            "arm64-linux" => "protoc-gen-twirp_ruby-#{VERSION}-linux-arm64.tar.gz",
            "x86_64-darwin" => "protoc-gen-twirp_ruby-#{VERSION}-darwin-amd64.tar.gz",
            "x86_64-linux" => "protoc-gen-twirp_ruby-#{VERSION}-linux-amd64.tar.gz"
            }

        end
    end
end