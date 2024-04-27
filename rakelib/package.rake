


VERSION = 'v1.8.0'

NATIVE_PLATFORMS = {
    "arm64-darwin" => "litestream-#{VERSION}-darwin-arm64.zip",
    "arm64-linux" => "litestream-#{VERSION}-linux-arm64.tar.gz",
    "x86_64-darwin" => "litestream-#{VERSION}-darwin-amd64.zip",
    "x86_64-linux" => "litestream-#{VERSION}-linux-amd64.tar.gz"
}

def litestream_download_url(filename)
    "https://github.com/arthurnn/twirp-ruby/releases/download/#{Litestream::Upstream::VERSION}/#{filename}"
end

