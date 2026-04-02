Pod::Spec.new do |s|
  s.name             = 'SecondPod'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight network listener for iOS.'

  s.description      = <<-DESC
    SecondPod is a lightweight Swift library that wraps Apple's Network framework
    to provide a simple, closure-based API for monitoring network connectivity changes.
    It reports connection status (Wi-Fi, cellular, wired Ethernet, loopback) and
    supports filtering by interface type.
  DESC

  s.homepage         = 'https://github.com/harshil-gandhi-us/SecondPod'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'harshil-gandhi-us' => 'harshil@logicwind.com' }
  s.source           = { :git => 'https://github.com/harshil-gandhi-us/SecondPod.git', :tag => s.version.to_s }

  s.ios.deployment_target  = '13.0'

  s.source_files     = 'Sources/SecondPod/**/*.swift'

  s.frameworks       = 'SystemConfiguration'
end
