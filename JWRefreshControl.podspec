#Intent.podspec
Pod::Spec.new do |s|
s.name         = "JWRefreshControl"
s.version      = "1.0.0"
s.summary      = "A refresh control(refresh header & footer for scrollview) for iOS app."

s.homepage     = "https://github.com/Jerry0523/JWRefreshControl"
s.license      = 'MIT'
s.author       = { "Jerry Wong" => "jerrywong0523@icloud.com" }
s.platform     = :ios, "8.0"
s.ios.deployment_target = "8.0"
s.source       = { :git => "https://github.com/Jerry0523/JWRefreshControl.git", :tag => s.version}
s.source_files  = 'JWRefreshControl/*.swift'
s.requires_arc = true
end
